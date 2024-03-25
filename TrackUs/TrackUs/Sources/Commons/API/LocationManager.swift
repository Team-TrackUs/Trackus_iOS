//
//  LocationManager.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/05.
//

import Foundation
import CoreLocation
import MapboxMaps

/**
 위치작업 관련 클래스
 */
final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var isUpdatingLocation: Bool = false
    
    
    override private init() {
        super.init()
        setLocationSettings()
        getCurrentLocation()
    }
    
    func setLocationSettings() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func getCurrentLocation() {
        locationManager.startUpdatingLocation()
        currentLocation = locationManager.location
    }
    
    /// 위치정보 상태 확인
    func checkLocationServicesEnabled(_ completion: @escaping (CLAuthorizationStatus) -> Void) {
        switch self.locationManager.authorizationStatus {
        case .authorizedAlways:
            completion(.authorizedAlways)
        case .notDetermined:
            completion(.notDetermined)
        case .authorizedWhenInUse:
            completion(.authorizedWhenInUse)
        case .restricted:
            completion(.restricted)
        case .denied:
            completion(.denied)
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
