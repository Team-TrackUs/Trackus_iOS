//
//  PushNotificationServiece.swift
//  TrackUs
//
//  Created by 최주원 on 4/1/24.
//
/// - accesstoken값 받아오는 방법 알아보기
/// - Notification -> topic 구독 방식으로 수정
/// -

import Foundation
import Firebase

class PushNotificationServiece {
    
    static let shared = PushNotificationServiece()
    
    private var projectId: String?
    private var serverKey: String?
    
    private init() {
        guard let url = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") else { return }
        guard let dictionary = NSDictionary(contentsOf: url) else { return }
        
        self.projectId = dictionary["PROJECT_ID"] as? String
        self.serverKey = dictionary["SERVER_KEY"] as? String
    }
    
    func sendPushNotificationTo(accessToken: String?, chatRoom: ChatRoom, members: [String : Member],body: String) {
        
        if chatRoom.group {
            // 그룹 채팅 경우
            for userId in chatRoom.nonSelfMembers{
                if let token = members[userId]?.token{
                    self.sendMessageToUser(accessToken: accessToken, to: token, title: "🏃🏻" + chatRoom.title, body: body, chatRoomID: chatRoom.id)
                }
            }
        }else {
            // 1:1 채팅 경우
            if let token = members[chatRoom.nonSelfMembers[0]]?.token {
                guard let uid = FirebaseManger.shared.auth.currentUser?.uid else {
                    return }
                self.sendMessageToUser(accessToken: accessToken, to: token, title: members[uid]!.userName, body: body, chatRoomID: chatRoom.id)
            }
        }
    }
    
    private func sendMessageToUser(accessToken: String?, to token: String, title: String, body: String, chatRoomID: String) {
        // 키값들 다른파일에 넣고 수정
        //guard let projectId = projectId else { return }
        guard let serverKey = serverKey else { return }
        
        //Cloud Messaging API 방식
        let urlStirng = "https://fcm.googleapis.com/fcm/send"
        
        // Firebase Cloud Messaging API(V1) 방식
        //let urlStirng = "https://fcm.googleapis.com/v1/projects/\(projectId)/messages:send"
        let url = NSURL(string: urlStirng)!
        let message: [String : Any] = [
            //"message": [
                // v1 - to, 기존 - token
            "to" : token,
            "notification" : [
                "title" : title,
                "body" : body
            ],
            "data" : [
            "chatRoomId" : chatRoomID
            ]
            //]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: message,
                                                       options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        //Cloud Messaging API 방식
        request.setValue("key= \(serverKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        
        task.resume()
    }
}
