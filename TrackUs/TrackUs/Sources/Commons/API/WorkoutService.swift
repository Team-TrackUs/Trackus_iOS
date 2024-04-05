//
//  WorkoutService.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation

struct WorkoutService {
    private init() {}
    
    /// 러닝페이스 구하기
    static func calcPace(second: Double, meter: Double) -> Double {
        return second / (meter / 1000)
    }
}
