//
//  HashableObject.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation

// 클래스를 Hashable한 타입으로 만들어줌
protocol HashableObject: Equatable {
    
}

extension HashableObject {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String {
        UUID().uuidString
    }
}
