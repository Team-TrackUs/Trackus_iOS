//
//  MainMapVC.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation
import MapboxMaps
import SwiftUI
import UIKit

struct MainMapVCHosting: UIViewControllerRepresentable {

    
    func makeUIViewController(context: Context) -> UIViewController {
        return MainMapVC()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    func makeCoordinator() -> MainMapVC {
        return MainMapVC()
    }
    
}

final class MainMapVC: UIViewController, GestureManagerDelegate {
    private var mapView: MapView!
    
    override func viewDidLoad() {
        setupMapView()
    }
    
    private func setupMapView() {
        let cameraOptions = CameraOptions(center: Constants.DEFAULT_LOCATION, zoom: 12)
        let options = MapInitOptions(cameraOptions: cameraOptions)
        self.mapView = MapView(frame: view.bounds, mapInitOptions: options)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.gestures.delegate = self
        self.mapView.mapboxMap.styleURI = .init(rawValue: "mapbox://styles/seokki/clslt5i0700m901r64bli645z")
        self.mapView.ornaments.options.scaleBar.visibility = .hidden
        self.mapView.ornaments.options.compass = .init(visibility: .hidden)
        
        self.view.addSubview(mapView)
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        
    }
}
