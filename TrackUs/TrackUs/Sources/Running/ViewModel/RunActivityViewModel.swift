//
//  HealthKitViewModel.swift
//  TrackUs
//
//  Created by 석기권 on 4/2/24.
//
// TODO: - 운동정보 계산시 HealthKit으로 리펙토링
// * 러닝시작
// - 거리, 소모칼로리, 페이스 구하기(시작 -> 현재의 최근데이터 누적)
// - 거리, 소모칼로리, 페이스 업데이트
// * 러닝중지
// - 추적중지
// * 재시작
// - 시작시간을 현재시간으로 업데이트
// - 러닝시작 단계 반복

import HealthKit
import MapboxMaps
import Firebase

final class RunActivityViewModel: ObservableObject, HashableObject {
    private var timer: Timer?
    private var observeQuery: HKObserverQuery!
    private let healthStore = HKHealthStore()
    private var anchor: HKQueryAnchor!
    private var startDate: Date?
    private let groupId: String
    
    @MainActor
    private var userUid: String {
        AuthenticationViewModel.shared.userInfo.uid
    }
    
    private var isGroup: Bool {
        !groupId.isEmpty
    }
    
    // 뷰에서 사용
    @Published var count = 3
    @Published var isPause = true
    @Published var isLoading = false
    
    // DB에 올라가는 데이터
    @Published var title = ""
    @Published var calorie = 0.0
    @Published var distance = 0.0
    @Published var seconds = 0.0
    @Published var target = 0.0
    @Published var pace = 0.0
    @Published var coordinates = [CLLocationCoordinate2D]()
    
    // 그룹러닝
    init(targetDistance target: Double, groupId: String) {
        self.target = target
        self.groupId = groupId
    }
    
    convenience init(targetDistance target: Double) {
        self.init(targetDistance: target, groupId: "")
    }
    
    /// 시작
    @MainActor
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.count -= 1
            if self.count == 0 {
                self.timer?.invalidate()
                
            }
        })
    }
    
    /// 기록
    func play() {
        self.startDate = Date()
        self.isPause = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            seconds += 1
        })
        
        // 러닝거리 운동에너지에 대한 데이터타입
        let distanceType = HKQuantityType(.distanceWalkingRunning)
        let activeEnergyType = HKQuantityType(.activeEnergyBurned)
        
        
        
        // 샘플유형 지정
        let distanceDescriptor = HKQueryDescriptor(sampleType: distanceType, predicate: nil)
        let activeEnergyDescriptor = HKQueryDescriptor(sampleType: activeEnergyType, predicate: nil)
        
        // 거리변화 감지시 호출됨
        observeQuery = HKObserverQuery(queryDescriptors: [distanceDescriptor, activeEnergyDescriptor])
        { query, updatedSampleTypes, completionHandler, error in
            
            if let error = error {
                debugPrint(#function + " HKObserverQuery " + error.localizedDescription)
                return
            }
            // 속성지정
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: Date(), options: .strictStartDate)
            
            if let types = updatedSampleTypes {
                // distanceWalkingRunning, activeEnergyBurned 샘플데이터 변경시
                let descriptors = types.map { type in
                    HKQueryDescriptor(sampleType: type, predicate: predicate)
                }
                
                let anchorQuery = HKAnchoredObjectQuery(queryDescriptors: descriptors,
                                                        anchor: self.anchor,
                                                        limit: HKObjectQueryNoLimit)
                { anchorQuery, samples, deleted, newAnchor, error in
                    if let error = error {
                        debugPrint(#function + " HKAnchoredObjectQuery " + error.localizedDescription)
                    }
                    
                    DispatchQueue.main.async {
                        // Update the anchor.
                        self.anchor = newAnchor
                        
                        // 가장 최근에 추가된 데이터 확인
                        guard let samples = samples,
                              let sample = samples.last,
                              let sampleQuantity = sample as? HKQuantitySample
                        else {  return }
                        
                        DispatchQueue.main.async {
                            if sampleQuantity.sampleType == distanceType {
                                self.distance += sampleQuantity.quantity.doubleValue(for: .meter())
                            } else if sampleQuantity.sampleType == activeEnergyType {
                                self.calorie += sampleQuantity.quantity.doubleValue(for: .kilocalorie())
                            }
                            self.pace = WorkoutService.calcPace(second: self.seconds, meter: self.distance)
                        }
                        
                        completionHandler()
                    }
                }
                self.healthStore.execute(anchorQuery)
            }
        }
        healthStore.execute(observeQuery)
    }
    
    /// 일시중지
    func pause() {
        isPause = true
        timer?.invalidate()
        healthStore.stop(observeQuery)
    }
    
    /// 중지
    func stop() {
        isPause = true
        timer?.invalidate()
        healthStore.stop(observeQuery)
    }
    
    /// 러닝데이터 추가(DB)
    func saveRunDataToFirestore() async throws {
        
        let uid = await userUid
        
        let data: [String : Any] = [
            "title": title,
            "distance": distance,
            "pace": pace,
            "calorie": calorie,
            "seconds": seconds,
            "target": target,
            "coordinates": coordinates.toGeoPoint,
            "isGroup": isGroup,
            "routeImageUrl": "",
            "address": "",
            "timestamp": Timestamp(date: Date())
        ]
        
        do {
            try await Firestore.firestore().collection("users").document(uid).collection("records").addDocument(data: data)
            
        } catch {
            debugPrint(error.localizedDescription)
            throw ErrorType.firebaseError
        }
    }
}
