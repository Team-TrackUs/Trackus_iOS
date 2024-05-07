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

extension RunActivityViewModel: HashableObject {}

final class RunActivityViewModel: ObservableObject {
    private var timer: Timer?
    private var anchorDate: Date?
    private var startDate: Date?
    private let groupId: String
    private let healthStore = HKHealthStore()
    private var caloriesQuery: HKStatisticsCollectionQuery!
    private var runningQuery: HKObserverQuery!
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
        stopTimer()
        healthStore.stop(caloriesQuery)
        healthStore.stop(runningQuery)
    }
    
    /// 중지
    func stop() {
        stopTimer()
        healthStore.stop(caloriesQuery)
        healthStore.stop(runningQuery)
    }
    
    /// 경로추가
    func addPath(withCoordinate coordinate: CLLocationCoordinate2D) {
        coordinates.append(coordinate)
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            seconds += 1
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    /// 기록
    func play() {
        self.anchorDate = Date()
        self.startDate = Date()
        self.startTimer()
        
        guard let activeEnergyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            fatalError("Unable to get the activeEnergyBurned type")
        }
        guard let distanceWalkingRunningType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("Unable to get the distanceWalkingRunning type")
        }
        
        // 시작시간으로부터 5초간
        var interval = DateComponents()
        interval.second = 5
        /**
         quantityType: 검색하려는 샘플 유형
         quantitySamplePredicate: 반환되는 결과에 대한 조건자
         options
         anchorDate: 샘플을 계산하는 순간을 지정(기준날짜)
         interval: 간격설정
         */
        caloriesQuery = HKStatisticsCollectionQuery.init(quantityType: activeEnergyBurnedType,
                                                         quantitySamplePredicate: nil,
                                                         options: .mostRecent,
                                                         anchorDate: anchorDate!,
                                                         intervalComponents: interval)
        
        caloriesQuery.statisticsUpdateHandler = { query, statistics, collection, error in
            guard let statisticsCollection = collection else {
                fatalError("Unable to get the activeEnergyBurned type")
            }
            
            statisticsCollection.enumerateStatistics(from: self.anchorDate!, to: Date()) { statistics, _ in
                // 가장 최근의 업데이트 결과를 반환
                if let calories = statistics.mostRecentQuantity() {
                    DispatchQueue.main.async {
                        self.calorie += calories.doubleValue(for: .kilocalorie())
                    }
                }
                self.anchorDate = Date() // 기준시간을 현재로 업데이트
            }
        }
        
        caloriesQuery.initialResultsHandler = { query, results, error in
        }
        
        runningQuery = HKObserverQuery(sampleType: distanceWalkingRunningType, predicate: nil) { (query, completionHandler, errorOrNil) in
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: Date(), options: .strictStartDate)
            let distanceQuery = HKStatisticsQuery(quantityType: distanceWalkingRunningType, quantitySamplePredicate: predicate, options: .mostRecent) { (query, result, error) in
                guard let result = result, let distance = result.mostRecentQuantity() else {
                    return
                }
                DispatchQueue.main.async {
                    self.distance += distance.doubleValue(for: .meter())
                    self.pace = WorkoutService.calcPace(second: self.seconds, meter: self.distance)
                }
            }
            self.healthStore.execute(distanceQuery)
        }
        
        healthStore.execute(caloriesQuery)
        healthStore.execute(runningQuery)
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


