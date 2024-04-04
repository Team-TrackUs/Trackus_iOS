//
//  PushNotificationServiece.swift
//  TrackUs
//
//  Created by 최주원 on 4/1/24.
//

import Foundation
import Firebase

class PushNotificationServiece {
    
    static let shared = PushNotificationServiece()
    
    private init() {}
    
    func sendPushNotificationTo(chatRoom: ChatRoom, members: [String : Member],body: String) {
        
        
        if chatRoom.group {
            for userId in chatRoom.nonSelfMembers{
                if let token = members[userId]?.token{
                    self.sendMessageToUser(to: token, title: "🏃🏻" + chatRoom.title, body: body)
                }
            }
        }else {
            if let token = members[chatRoom.nonSelfMembers[0]]?.token{
                guard let uid = FirebaseManger.shared.auth.currentUser?.uid else {
                    return }
                self.sendMessageToUser(to: token, title: members[uid]!.userName, body: body)
            }
        }
    }
    
    private func sendMessageToUser( to token: String, title: String, body: String) {
        let serverKey =  "AAAAWFaAG50:APA91bFwg2klLAIRtX0b1H16PyqedZQ1kzzRXXkY3NOmVjjB5wv7x_FoxDwAzwpVOO2TeBdW2JqapqvZ9ttrvzlmU7jlkqDVD7lcmO3zG1zlvzyew4pUWhVlMRUhGeGdBKsU6jmU3ssi"
        
        let urlStirng = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlStirng)!
        let paramString: [String : Any] = [
            "to" : token,
            "notification" : [
                "title" : title,
                "body" : body
            ]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString,
                                                       options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key= \(serverKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        
        task.resume()
    }
}
