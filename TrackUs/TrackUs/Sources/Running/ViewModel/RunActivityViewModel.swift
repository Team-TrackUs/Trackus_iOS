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
// TODO: - 20240406
// - 칼로리 받아오지 않는문제
// - 페이스값 오류
// - 스크린샷 저장
// - 러닝결과
// TODO: - 20240408
// - 화면넘어가는 오류
// - 스크린샷 저장 오류


import UIKit
import HealthKit
import MapboxMaps
import Firebase

final class RunActivityViewModel: ObservableObject, HashableObject {
    private var timer: Timer?
    private var startDate: Date?
    private let groupId: String
    private var observeQuery: HKObserverQuery!
    private let healthStore = HKHealthStore()
    private var anchor: HKQueryAnchor!
    private var snapshot: UIImage?
    var isGroup: Bool {
        !groupId.isEmpty
    }
    
    // 뷰에서 사용
    @Published var count = 3
    @Published var isLoading = false
    
    
    // DB에 올라가는 데이터
    @Published var title = ""
    @Published var calorie = 0.0
    @Published var distance = 0.0
    @Published var seconds = 0.0
    @Published var target = 0.0
    @Published var pace = 0.0
    var coordinates = [CLLocationCoordinate2D]()
    
    // 그룹러닝
    init(targetDistance target: Double, groupId: String) {
        self.target = target
        self.groupId = groupId
    }
    
    // 개인러닝
    convenience init(targetDistance target: Double) {
        self.init(targetDistance: target, groupId: "")
    }
    
    func addSnapshot(withImage snapshot: UIImage) {
        self.snapshot = snapshot
    }
    
    /// 시작
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.count -= 1
            if self.count == 0 {
                self.timer?.invalidate()
            }
        })
    }
    
    /// 일시중지
    func pause() {
        timer?.invalidate()
        healthStore.stop(observeQuery)
    }
    
    /// 중지
    func stop() {
        timer?.invalidate()
        healthStore.stop(observeQuery)
    }
    
    /// 경로추가
    func addPath(withCoordinate coordinate: CLLocationCoordinate2D) {
        coordinates.append(coordinate)
    }

    /// 기록
    func play() {
        self.startDate = Date()
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
            
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: Date())
            
            if let types = updatedSampleTypes {
                
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
                    
                        self.anchor = newAnchor
                        
                        // 가장 최근에 추가된 데이터 확인
                        guard let samples = samples,
                              let sample = samples.last,
                              let sampleQuantity = sample as? HKQuantitySample
                        else {  return }
            
                        DispatchQueue.main.async {
                            if sampleQuantity.sampleType == activeEnergyType {
                                self.calorie += sampleQuantity.quantity.doubleValue(for: .kilocalorie())
                            }
                            if sampleQuantity.sampleType == distanceType {
                                self.distance += sampleQuantity.quantity.doubleValue(for: .meter())
                            }
                            
                            self.pace = WorkoutService.calcPace(second: self.seconds, meter: self.distance)
                        }
                        
                        completionHandler()
                    
                }
                self.healthStore.execute(anchorQuery)
            }
        }
        healthStore.execute(observeQuery)
    }
    
    /// 러닝데이터 추가(DB)
    func saveRunDataToFirestore() async throws {
        let uid = await AuthenticationViewModel.shared.userInfo.uid
        guard let image = snapshot else { return }
        let coordinate = coordinates.first ?? CLLocationCoordinate2D(latitude: 37.570946308046466, longitude: 126.97893407434964)
        
        do {
            let imageUrl = try await ImageUploader.uploadImageAsync(image: image, type: .map)
            let address = try await LocationService.convertToAddressAsync(coordinate: coordinate.asCLLocation)
            
            let title = title.isEmpty ? "\(address)에서 러닝" : title
            
            let data: [String : Any] = [
                "title": title,
                "distance": distance,
                "pace": pace,
                "calorie": calorie,
                "seconds": seconds,
                "target": target,
                "coordinates": coordinates.toGeoPoint,
                "isGroup": isGroup,
                "routeImageUrl": imageUrl,
                "address": address,
                "timestamp": Timestamp(date: Date())
            ]
            
            try await Firestore.firestore().collection("users").document(uid).collection("records").addDocument(data: data)
            
        } catch {
            debugPrint(#function + error.localizedDescription)
            throw error
        }
    }
}

