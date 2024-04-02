//
//  HealthKitService.swift
//  TrackUs
//
//  Created by 석기권 on 4/2/24.
//

import Foundation
import HealthKit

class HealthKitService {
    let healthStore = HKHealthStore()
    
    enum HKAuthorizationStatus {
        case notAvailableOnDevice
        case availableOnDevice
    }
    
    /// 거리 활동에너지 권한을 요청
    static let typesToShare: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    /// HealthKit 권한체크
    class func requestAuthorization() async -> HKAuthorizationStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .notAvailableOnDevice
        }
        
        do {
            try await HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToShare)
        } catch {
            return .notAvailableOnDevice
        }
        
        return .availableOnDevice
    }
}


