//
//  HealthKitService.swift
//  TrackUs
//
//  Created by 석기권 on 4/2/24.
//

import Foundation
import HealthKit

class HealthKitService {
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
    }
    
    /// 거리 활동에너지 권한을 요청
    static let typesToShare: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    ]
    
    /// HealthKit 권한체크
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        HKHealthStore().requestAuthorization(toShare: typesToShare,
                                             read: typesToShare) { (success, error) in
            print(success)
            completion(success, error)
            return
        }
    }
    
    class func getAuthorizeStatus(completion: @escaping (HKAuthorizationStatus) -> Void) {
        let authorizationStatus = HKHealthStore().authorizationStatus(for: .activitySummaryType())
        
        switch authorizationStatus {
        case .notDetermined:
            completion(.notDetermined)
        case .sharingDenied:
            completion(.sharingDenied)
        case .sharingAuthorized:
            completion(.sharingAuthorized)
        default:
            break
        }
    }
}

extension HKAuthorizationStatus {
    var message: String {
        switch self {
        case .notDetermined:
            "권한이 아직 요청되지 않았습니다."
        case .sharingDenied:
            "권한을 허용하여 정확한 운동 정보를 확인할 수 있습니다 설정으로 이동하여 권한을 허용해주세요."
        case .sharingAuthorized:
            "권한부여가 완료되었습니다."
        default:
            ""
        }
    }
}
