//
//  WorkoutService.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation

struct WorkoutService {
    let distance: Double
    let target: Double
    let seconds: Double
    let calorie: Double
    
    let savedDistance = UserDefaults.standard.double(forKey: "savedDistance")
    let savedTime = UserDefaults.standard.double(forKey: "savedTime")
    
    var kilometerDiff: Double {
        abs(distance - savedDistance)
    }
    
    @MainActor
    var calorieDiff: Double {
        abs(calorie - Self.calcCaloriesBurned(distance: savedDistance))
    }
    
    var timeDiff: Double {
        abs(seconds - savedTime)
    }
    
    @MainActor
    var estimatedCalorie: Double {
        Self.calcCaloriesBurned(distance: savedDistance)
    }
    
    @MainActor
    var compKilometerLabel: String {
        "\(distance.asString(unit: .kilometer)) / \(target.asString(unit: .kilometer))"
    }
    
    @MainActor
    var compCaloriesLabel: String {
        "\(calorie.asString(unit: .calorie)) / \(estimatedCalorie.asString(unit: .calorie))"
    }
    
    @MainActor
    var compElapsedTimeLabel: String {
        "\(seconds.asString(style: .positional)) / \(savedTime.asString(style: .positional))"
    }
    
    var kilometerReached: Bool {
        distance > savedDistance
    }
    
    @MainActor
    var calorieReached: Bool {
        calorie > estimatedCalorie
    }
    
    var timeReached: Bool {
        seconds < savedTime
    }
    
    @MainActor
    var kilometerAchievement: String {
        let isSameValue = distance == savedDistance
        
        if isSameValue {
            return "목표하신 \(distance) 러닝을 완료했어요 🎉"
        } else if kilometerReached {
            return "\(kilometerDiff) 만큼 더 뛰었습니다!"
        } else {
            return "\(kilometerDiff) 적게 뛰었어요."
        }
    }
    
    @MainActor
    var calcAchievement: String {
        let isSameValue = calorie == estimatedCalorie
        
        if isSameValue {
            return "목표치인 \(calorie.asString(unit: .calorie)) 만큼 소모했어요 🔥"
        } else if calorieReached {
            return "\(calorieDiff.asString(unit: .calorie)) 더 소모했어요!"
        } else {
            return "\(kilometerDiff.asString(unit: .calorie)) 덜 소모했어요."
        }
    }
    
    @MainActor
    var timeAchievement: String {
        let isSameValue = seconds == savedTime
        if isSameValue {
            return "목표하신 시간내에 러닝을 완료했어요! 🎉"
        } else if timeReached {
            return "\(timeDiff.asString(style: .positional)) 만큼 단축되었어요! 🔥"
        } else {
            return "\(timeDiff.asString(style: .positional)) 만큼 더 소요되었어요."
        }
    }
    
    @MainActor
    var feedbackMessageLabel: String {
        if kilometerReached, timeReached, calorieReached {
            return "대단해요! 목표를 달성하고 도전 시간을 단축하고 그에따른 운동량도 증가했습니다. 지속적으로 노력해서 운동능력을 향상시켜 보세요!"
        } else if kilometerReached, calorieReached {
            return "목표하신 거리와 운동량을 달성했어요! 무리가 가지않는다면 조금씩 페이스를 올려봐도 좋을것 같습니다!"
        }
        else if kilometerReached, timeReached {
            return "멋지군요! 목표하신 거리를 달성하고 시간이 단축되었어요 기록단축이 목적이 아니라면 운동량을 늘려도 좋을것 같아요."
        } else if kilometerReached {
            return "목표하신 거리에 도달했습니다! 현재 페이스가 무리되지 않는다면 조금씩 페이스를 올려도 좋을것 같아요!"
        } else if timeReached {
            return "목표거리에 도달하지 못했어요 지속적으로 거리를 조금씩 증가시키면서 운동량을 증가시켜보세요."
        } else if calorieReached {
            return "목표거리에 도달하지 못했지만 운동량을 달성했습니다!"
        } else {
            return "목표에 도달하지 못했어요 괜찮아요. 중요한건 지속적으로 목표와 거리를 설정하고 도전 하는것입니다."
        }
    }

    @MainActor
    static func calcCaloriesBurned(distance: Double) -> Double {
            var caloriesPerMeters: Double
            let myRunningStyle = AuthenticationViewModel.shared.userInfo.runningStyle ?? .jogging
            switch myRunningStyle {
            case .walking:
                caloriesPerMeters = 0.041 // 보행에 따른 칼로리 소모량
            case .jogging:
                caloriesPerMeters = 0.063 // 조깅에 따른 칼로리 소모량
            case .running:
                caloriesPerMeters = 0.080 // 러닝에 따른 칼로리 소모량
            case .interval:
                caloriesPerMeters = 0.1 // 스프린트에 따른 칼로리 소모량
            }
            
            let caloriesBurned = distance * caloriesPerMeters
            
            return caloriesBurned
        }
    
    @MainActor
      static func calculateEstimatedTime(distance: Double, style: RunningStyle? = nil) -> Double {
          let myRunningStyle = AuthenticationViewModel.shared.userInfo.runningStyle ?? .jogging
          
          switch myRunningStyle {
          case .walking:
              return floor(distance * 0.9)
          case .jogging:
              return floor(distance * 0.45)
          case .running:
              return floor(distance * 0.3)
          case .interval:
              return floor(distance * 0.15)
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
}
