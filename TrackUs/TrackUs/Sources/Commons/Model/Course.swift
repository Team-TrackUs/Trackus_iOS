//
//  Course.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/23.
//

import FirebaseFirestoreSwift
import Firebase
import MapboxMaps

struct Course: Decodable, Hashable {
    @DocumentID var id: String?
    let uid: String
    let title: String
    let content: String
    let courseRoutes: [GeoPoint]
    let distance: Double
    let estimatedTime: Int
    let participants: Int
    let runningStyle: String
    let startDate: Date
    let members: [String]
    
    var coordinates: [CLLocationCoordinate2D] {
        self.courseRoutes.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)}
    }
}
