//
//  UserInfo.swift
//  TrackUs
//
//  Created by 최주원 on 2/7/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

enum RunningStyle: String, Codable, CaseIterable, Identifiable  {
    case walking = "walking"
    case jogging = "jogging"
    case running = "running"
    case interval = "interval"
    
    var id: Self {self}
    
    var description: String {
        switch self {
        case .walking: return "걷기"
        case .jogging: return "조깅"
        case .running: return "달리기"
        case .interval: return "인터벌"
        }
    }
}

struct UserInfo : Codable {
    // 본인 프로필사진 저장용
    var image: UIImage?
    
    var uid: String
    var username: String
    var weight: Int?
    var height: Int?
    var age: Int?
    var gender: Bool?
    var isProfilePublic: Bool
    var isProSubscriber: Bool
    var profileImageUrl: String?
    var setDailyGoal: Double?
    var runningStyle: RunningStyle?
    var token: String
    var isBlock: Bool
    /// 차단한 사용자 리스트
    var blockedUserList: [String]?
    var blockingMeList: [String]?
    /// 필터링용도 List : 본인이 차단한 사용자 + 본인을 차단한 사용자 리스트
    var blockList: [String] {
        var result: [String] = []
        if let blockedUserList = blockedUserList{
            result += blockedUserList
        }
        if let blockingMeList = blockingMeList {
            result += blockingMeList
        }
        return result
    }
    // 신고 누적 횟수
    var reportIDList: [String]?
    
    init(){
        self.uid = ""
        self.username = ""
        self.isProfilePublic = false
        self.isProSubscriber = false
        self.token = ""
        self.isBlock = false
       // self.blockUserList = [""]
        //self.blockedUserMeList = [""]
    }
    
    enum CodingKeys:String, CodingKey {
        case uid = "uid"
        case username = "username"
        case weight = "weight"
        case height = "height"
        case age = "age"
        case gender = "gender"
        case isProfilePublic = "isProfilePublic"
        case isProSubscriber = "isProSubscriber"
        case profileImageUrl = "profileImageUrl"
        case setDailyGoal = "setDailyGoal"
        case runningStyle = "runningStyle"
        case token = "token"
        case isBlock = "isBlock"
        case blockedUserList = "blockedUserList"
        case blockingMeList = "blockingMeList"
        case reportIDList = "reportIDList"
    }
}
