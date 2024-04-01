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
    
    func sendPushNotificationTo(chatRoom: ChatRoom, body: String, chatRoomId: String) {
        
//        if chatRoom.group {
            for userId in chatRoom.nonSelfMembers{
                self.sendMessageToUser(to: userId, title: chatRoom.title, body: body, chatRoomId: chatRoom.id)
            }
//        }else{
//            self.sendMessageToUser(to: userId, title: chatRoom.title, body: body, chatRoomId: chatRoom.id)
//        }
        
        //firebaseUser
        
    }
    
    private func sendMessageToUser( to token: String, title: String, body: String, chatRoomId: String) {
        
        let urlStirng = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlStirng)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : [
                                            "title" : title,
                                            "body" : body,
                                            "badge" : "1",
                                            "sound" : "default"
                                           ]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString,
                                                       options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setNilValueForKey("key= \(kSE)")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        
        task.resume()
    }
}
