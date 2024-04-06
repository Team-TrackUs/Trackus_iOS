//
//  SettingViewModel.swift
//  TrackUs
//
//  Created by 석기권 on 4/4/24.
//

import Foundation

final class SettingViewModel: ObservableObject {
    let userDefaults = UserDefaults.standard
    
    @Published var distance: Double {
        didSet {
            DispatchQueue.main.async { [self] in
                estimatedTime = WorkoutService.calculateEstimatedTime(distance: distance)
            }
        }
    }
    @Published var estimatedTime: Double
    
    private let savedDistance = "savedDistance"
    private let savedTime = "savedTime"
    private let defaultDistance = 3000.0
    private let defaultTime = 900.0
    
    init() {
        let savedDistance = userDefaults.double(forKey: savedDistance)
        let savedTime = userDefaults.double(forKey: savedTime)
        
        if savedDistance == 0 || savedTime == 0 {
            self.distance = defaultDistance
            self.estimatedTime = defaultTime
        } else {
            self.distance = savedDistance
            self.estimatedTime = savedTime
        }
    }
    
    /// 설정저장
    func save() {
        userDefaults.set(distance, forKey: savedDistance)
        userDefaults.set(estimatedTime, forKey: savedTime)
    }
}
