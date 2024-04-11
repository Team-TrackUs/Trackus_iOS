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
    private var coordinates: [CLLocationCoordinate2D]
    private var snapshot: UIImage?
    var screenshotHandler: ((UIImage) -> Void)?
    
    init(coordinates: [CLLocationCoordinate2D], snapshot: UIImage? = nil, screenshotHandler: ((UIImage) -> Void)? = nil) {
        self.coordinates = coordinates
        self.snapshot = snapshot
        self.screenshotHandler = screenshotHandler
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return MainMapVC(coordinates: coordinates,
                         screenshotHandler: screenshotHandler)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    func makeCoordinator() -> MainMapVC {
        return MainMapVC(coordinates: coordinates,
                         screenshotHandler: screenshotHandler)
    }
    
}

final class MainMapVC: UIViewController, GestureManagerDelegate {
    private var mapView: MapView!
    private var coordinates: [CLLocationCoordinate2D] = []
    private var screenshotHandler: ((UIImage) -> Void)?
    
    init(coordinates: [CLLocationCoordinate2D], screenshotHandler: ((UIImage) -> Void)? = nil) {
        self.coordinates = coordinates
        self.screenshotHandler = screenshotHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupMapView()
        drawPathLine()
        setBoundsOnCenter()
    }
    
    private func setupMapView() {
        guard let centerPosition = self.coordinates.centerCoordinate else {
            return
        }
        
        let cameraOptions = CameraOptions(center: centerPosition, zoom: 17)
        let options = MapInitOptions(cameraOptions: cameraOptions)
        self.mapView = MapView(frame: view.bounds, mapInitOptions: options)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.ornaments.options.scaleBar.visibility = .hidden
        self.mapView.mapboxMap.styleURI = .init(rawValue: "mapbox://styles/seokki/clslt5i0700m901r64bli645z")
        
        self.mapView.ornaments.options.compass = .init(visibility: .hidden)
        
        view.addSubview(mapView)
    }
    
    private func drawPathLine() {
        self.drawPath()
        if coordinates.first! == coordinates.last! {
            self.mapView.makeMarkerWithUIImage(coordinate: self.coordinates.first!, imageName: "start_icon")
        } else {
            self.mapView.makeMarkerWithUIImage(coordinate: self.coordinates.first!, imageName: "start_icon")
            self.mapView.makeMarkerWithUIImage(coordinate: self.coordinates.last!, imageName: "puck_icon")
        }
    }
    
    /// 경로 그리기
    private func drawPath() {
        var lineAnnotation = PolylineAnnotation(lineCoordinates: coordinates)
        lineAnnotation.lineColor = StyleColor(UIColor.main)
        lineAnnotation.lineWidth = 5
        lineAnnotation.lineJoin = .round
        let lineAnnotationManager = mapView.annotations.makePolylineAnnotationManager()
        lineAnnotationManager.annotations = [lineAnnotation]
    }
    
    private func setBoundsOnCenter(completion: (() -> ())? = nil) {
        let camera = try? self.mapView.mapboxMap.camera(
            for: coordinates,
            camera: self.mapView.mapboxMap.styleDefaultCamera,
            coordinatesPadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
            maxZoom: nil,
            offset: nil
        )
        
        self.mapView.camera.ease (
            to: camera!,
            duration: 0) { _ in
                self.takeSnapshot()
            }
    }
    
    private func takeSnapshot() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let image = UIImage.imageFromView(view: self.mapView), let screenshotHandler = self.screenshotHandler {
                screenshotHandler(image)
            }
        }
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        
    }
}
