////
////  MapView.swift
////  TrackUs
////
////  Created by 석기권 on 4/5/24.
////
//
//import Foundation
//import MapboxMaps
//
//struct MapView: UIViewControllerRepresentable {
//    enum MapStyle {
//        case standard
//        case numberd
//    }
//    
//    var mapStyle: MapboxMapView.MapStyle = .standard
//    var isUserInteractionEnabled: Bool = true
//    let coordinates: [CLLocationCoordinate2D]
//
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        return MapboxMapViewController(coordinates: coordinates,
//                                       mapStyle: mapStyle, isUserInteractionEnabled: isUserInteractionEnabled)
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//    }
//    
//    func makeCoordinator() -> MapboxMapViewController {
//        return MapboxMapViewController(coordinates: coordinates,
//                                       mapStyle: mapStyle, isUserInteractionEnabled: isUserInteractionEnabled)
//    }
//}
