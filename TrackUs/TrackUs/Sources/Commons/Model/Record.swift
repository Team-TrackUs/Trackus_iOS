//
//  Record.swift
//  TrackUs
//
//  Created by 석기권 on 3/25/24.
//

import Foundation
import Firebase

/**
 러닝기록(개인, 그룹)
 calorie: 소모칼로리
 distance: 이동거리
 time: 경과시간
 pace: 평균페이스
 coordinates: 이동경로 좌표
 address: 주소
 groupID: 그룹ID
 routeImageUrl: 경로이미지 URL
 targetDistance: 목표거리
 createdAt: 생성시간
 */
struct Record: Codable, Hashable {
    var calorie: Double
    var distance: Double
    var time: Double
    var target: Double
    var pace: Double
    var coordinates: [GeoPoint]
    var address: String
    var groupID: String
    var routeImageUrl: String
    var createdAt: Date?
    
    var isGroup: Bool {
        !groupID.isEmpty
    }
}

extension Record {
    var identifier: String {
        return UUID().uuidString
    }
    public static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
}
