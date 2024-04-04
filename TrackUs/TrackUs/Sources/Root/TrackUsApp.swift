//
//  TrackUsApp.swift
//  TrackUs
//
//  Created by 박소희 on 1/29/24.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        // 메세지 델리게이트
        Messaging.messaging().delegate = self
        
        // 현재 등록 토큰 가져오기
        Messaging.messaging().token { token, error in
            if let error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token {
                print("FCM registration token: \(token)")
            }
        }
        
        // push 포그라운드 설정
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // 백그라운드 자동 push 알림
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
    }
    
    // fcm 토큰 등록 되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func updateUserToken(newToken: String) {
        AuthenticationViewModel.shared.updateToken(newToken)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    // 앱이 켜져있을때 푸시메세지 받아올때
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // 신규 추가
        // Do Something With MSG Data...
//            if let messageID = userInfo[gcmMessageIDKey] {
//                print("Message ID: \(messageID)")
//            }
            
            
            print(userInfo)
        // =====
        
        completionHandler([.banner, .sound, .badge])
    }
    
    // 푸시메세지 받을때
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        //신규추가
        NotificationCenter.default.post(
                    name: Notification.Name("didReceiveRemoteNotification"),
                    object: nil,
                    userInfo: userInfo
                )
        
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - token: \(String(describing: fcmToken))")
        updateUserToken(newToken: fcmToken ?? "")
    }
}

@main
struct TrackUsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(Router())
        }
    }
}


