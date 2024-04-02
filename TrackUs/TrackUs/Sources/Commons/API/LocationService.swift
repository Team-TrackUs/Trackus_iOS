//
//  LocationService.swift
//  TrackUs
//
//  Created by 석기권 on 4/2/24.
//

import Foundation
import CoreLocation
import MapboxMaps

/**
 위치작업 관련 클래스
 */
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    
    
    override private init() {
        super.init()
        setLocationSettings()
        getCurrentLocation()
    }
    
    /// 위치관련 설정
    func setLocationSettings() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    /// 현재위치 업데이트
    func getCurrentLocation() {
        locationManager.startUpdatingLocation()
        currentLocation = locationManager.location
    }
    
    /// 위치정보 상태 확인
    func checkLocationServicesEnabled() async -> CLAuthorizationStatus {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways:
            return CLAuthorizationStatus.authorizedAlways
        case .notDetermined:
            return CLAuthorizationStatus.notDetermined
        case .authorizedWhenInUse:
            return CLAuthorizationStatus.authorizedWhenInUse
        case .restricted:
            return CLAuthorizationStatus.restricted
        case .denied:
            return CLAuthorizationStatus.denied
        @unknown default:
            fatalError("Unable to check location permission information")
        }
    }
    
    /// 위도, 경도를 받아서 한글주소로 반환
    func convertToAddressWith(coordinate: CLLocation, completion: @escaping (String) -> ()) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(coordinate) { placemarks, error in
            if error != nil {
                completion("위치정보 없음")
                return
            }
            
            if let address: [CLPlacemark] = placemarks {
                let city = address.last?.administrativeArea
                let state = address.last?.subLocality
                
                if let city = city, let state = state {
                    completion("\(city) \(state)")
                } else if let city = city {
                    completion("\(city)")
                } else if let state = state {
                    completion("\(state)")
                } else {
                    completion("위치정보 없음")
                }
            }
        }
    }
    
}


