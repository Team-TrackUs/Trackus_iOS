//
//  WorkoutService.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation

struct WorkoutService {
    let isGroup: Bool
    let measuringDistance: Double
    let measuringMomentum: Double
    let measurementTime: Double
  
    var distanceCompString: String {
        return "\(measuringDistance.asString(unit: .kilometer))"
    }
    
    var calorieCompString: String {
        return "\(measuringMomentum.asString(unit: .calorie))"
    }
    
    var timeCompString: String {
        return "\(measurementTime.asString(style: .positional))"
    }
}

extension WorkoutService {
    /// 러닝페이스 구하기
    static func calcPace(second: Double, meter: Double) -> Double {
        let timeInMinutes = second / 60.0
        let pace = timeInMinutes / (meter / 1000)
        return pace
    }
    
    static func calcEstimatedTime(distance: Double, style: RunningStyle? = nil) -> Double {
        return floor(distance * 0.45)
    }
    
    static func calcCaloriesBurned(distance: Double) -> Double {
        let caloriesBurned = distance * 0.063
        return caloriesBurned
    }
}
