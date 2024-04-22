//
//  WorkoutService.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation



struct WorkoutService {
    struct WorkoutSummary {
        var distance: String = ""
        var caclorie: String = ""
        var time: String = ""
        var review: String = ""
    }
    let isGroup: Bool
    let measuringDistance: Double // 측정거리
    let measuringMomentum: Double // 운동량
    let measurementTime: Double // 측정시간
    var targetDistance: Double = 0.0 // 목표거리
    
    var targetDist: Double {
        isGroup ? targetDistance : UserDefaults.standard.double(forKey: "savedDistance")
    }
    
    var estimatedCalorie: Double {
        WorkoutService.calcCaloriesBurned(distance: targetDist)
    }
    
    var estimatedTime: Double {
        WorkoutService.calcEstimatedTime(distance: targetDist)
    }
  
    var distanceCompString: String {
        "\(measuringDistance.asString(unit: .kilometer)) / \(targetDist.asString(unit: .kilometer))"
    }
    
    var calorieCompString: String {
       "\(measuringMomentum.asString(unit: .calorie)) / \(estimatedCalorie.asString(unit: .calorie))"
    }
    
    var timeCompString: String {
        "\(measurementTime.asString(style: .positional)) / \(WorkoutService.calcEstimatedTime(distance: targetDist).asString(style: .positional))"
    }
    
    var workoutSummary: WorkoutSummary {
        var summary = WorkoutService.WorkoutSummary()
        
        let isDistSame = targetDist == measuringDistance, 
            isDistGoal = measuringDistance > targetDist,
            distDiff = abs(targetDist - measuringDistance)

        let isCalorieSame = measuringMomentum == estimatedCalorie,
            isCalorieGoal = measuringMomentum > estimatedCalorie,
            calorieDiff = abs(measuringMomentum - estimatedCalorie)
        
        let isTimeSame = measurementTime == estimatedTime,
            isTimeGoal = measurementTime < estimatedTime,
            timeDiff = abs(measurementTime - estimatedTime)
        
        if isDistSame {
            summary.distance = "목표치 \(measuringDistance.asString(unit: .kilometer))에 도달했어요! 🎉"
        } else if isDistGoal {
            summary.distance = "대단해요 \(distDiff.asString(unit: .kilometer)) 더 뛰었어요! 🔥"
        } else {
            summary.distance = "목표거리에 도달하지 못했어요."
        }
        
        if isCalorieSame {
            summary.caclorie = "목표치 \(calorieDiff.asString(unit: .calorie))에 도달했어요! 🎉"
        } else if isCalorieGoal {
            summary.caclorie = "대단해요 \(calorieDiff.asString(unit: .calorie))만큼 더 소모했어요! 🔥"
        } else {
            summary.caclorie = "목표 운동량에 도달하지 못했어요."
        }
        
        if isTimeSame {
            summary.time = "정확히 \(estimatedTime.asString(style: .positional))에 완주했어요!"
        } else if isTimeGoal {
            summary.time = "목표보다 \(timeDiff.asString(style: .positional))만큼 단축했어요! 🔥"
        } else {
            summary.time = "목표시간에 도달하지 못했어요."
        }
        
        if isDistGoal, isCalorieGoal, isTimeGoal {
            summary.review = "목표 거리와 운동량을 동시에 달성하고 시간까지 단축했어요! 앞으로도 지속적으로 시간을 단축하면서 운동량을 증가시키면 운동능력을 향상시켜 보세요!"
        } else if isDistGoal, isCalorieGoal {
            summary.review = "목표 거리와 운동량을 달성했지만 시간은 단축하지 못했어요 몸에 무리가 되지 않는다면 페이스를 조금 올려도 좋을 것 같습니다!"
        } else if isDistGoal {
            summary.review = "목표 거리에 도달했습니다! 기록 단축이 목표가 아니라면 지금처럼 꾸준히 목표를 달성하면 운동능력이 향상될 것입니다."
        } else if isCalorieGoal {
            summary.review = "목표 거리에 도달하지 못했지만 충분한 운동이 되었습니다. 다음부터는 목표 도달에 집중해도 좋을 것 같습니다."
        } else if isTimeGoal {
            summary.review = "목표하신 시간보다 단축됐지만 목표 거리에 도달하지 못했어요. 무리가 된다면 목표 거리를 줄이고 조금씩 거리를 늘려보세요."
        } else {
            summary.review = "목표에 도달하지 못했지만 중요한 것은 적절한 목표를 설정하고 지속적으로 도전하는 것입니다. 꾸준히 운동하면 좋은 결과가 예상됩니다."
        }
        
        return summary
    }
    
    var distanceCompMessage: String {
        let isSameValue = targetDist == measuringDistance
        let isGoalValue = measuringDistance > targetDist
        let distDiff = abs(targetDist - measuringDistance)
        
        if isSameValue {
            return "목표치 \(measuringDistance.asString(unit: .kilometer))에 도달했어요! 🎉"
        } else if isGoalValue {
            return "대단해요 \(distDiff.asString(unit: .kilometer)) 더 뛰었어요! 🔥"
        } else {
            return "목표거리에 도달하지 못했어요."
        }
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
