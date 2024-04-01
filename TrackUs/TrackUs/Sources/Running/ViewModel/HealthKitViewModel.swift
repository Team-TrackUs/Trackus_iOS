//
//  HealthKitViewModel.swift
//  TrackUs
//
//  Created by 석기권 on 4/2/24.
//

import HealthKit
import MapboxMaps

final class HealthKitViewModel: ObservableObject {
    private let id = UUID()
    private let healthStore = HKHealthStore()
    private var timer: Timer?
    
    @Published var count = 3
    @Published var isPause = true
    
    @Published var calorie = 0.0
    @Published var distance = 0.0
    @Published var seconds = 0.0
    @Published var target = 0.0
    @Published var pace = 0.0
    @Published var coordinates = [CLLocationCoordinate2D]()
    
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
        isPause = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            seconds += 1
        })
    }
    
    /// 일시중지
    func pause() {
        isPause = true
        timer?.invalidate()
    }
    
    /// 중지
    func stop() {
        isPause = true
        timer?.invalidate()
    }
}

extension HealthKitViewModel: Hashable {
    static func == (lhs: HealthKitViewModel, rhs: HealthKitViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

