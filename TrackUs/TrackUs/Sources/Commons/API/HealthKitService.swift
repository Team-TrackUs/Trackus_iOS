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
    
    enum HKAuthorizationStatus: Error {
        case notAvailableOnDevice
        case availableOnDevice
    }
    
    
    static let typesToShare: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    static let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    ]
    
    
     static func requestAuthorization() async {
        do {
          try await HKHealthStore().requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
        }
    }
    
    func checkReadTypePersmission() async -> Bool {
        let samplesType: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                              HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.day = components.month! - 1
        let oneMonthAgo = calendar.date(from: components)
       
        let queryPredicate = HKQuery.predicateForSamples(withStart: oneMonthAgo, end: .now, options: .strictEndDate)
        let queryDescriptor = HKSampleQueryDescriptor(
         predicates: [
            .quantitySample(type: HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!, predicate: queryPredicate),
            .quantitySample(type: HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!, predicate: queryPredicate)
         ],
         sortDescriptors: [],
         limit: 1
        )
        
        do {
            let result = try await queryDescriptor.result(for: healthStore)
            if result.isEmpty {
                return false
            } else {
                return true
            }
        } catch {
            return false
        }
    }
}


