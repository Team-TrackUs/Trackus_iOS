//
//  Constants.swift
//  TrackUs
//
//  Created by SeokKi Kwon on 2024/01/29.
//

import Foundation
import Firebase
import MapboxMaps

enum Constants {
    // 기본위치 상수, 광화문
    static let DEFAULT_LOCATION = CLLocationCoordinate2D(latitude: 37.570946308046466, longitude: 126.97893407434964)
    
    enum WebViewUrl {
        static let TERMS_OF_SERVICE_URL = "https://lizard-basketball-e41.notion.site/TrackUs-6015541452f14ed2b2f1541e5259ea72?pvs=4"
        static let OPEN_SOURCE_LICENSE_URL = "https://lizard-basketball-e41.notion.site/a57a3078e21c4821932d2189859b8bcb?pvs=4"
        static let SERVICE_REQUEST_URL = "https://forms.gle/drvCZV4kHdgZJonRA"
        static let TEAM_INTRO_URL = "https://lizard-basketball-e41.notion.site/Team-TrackUs-2d71e86df51f4bbba4b0b7a5b04ac947?pvs=4"
        static let Team_Trackus_GitHub_URL = "https://github.com/Team-TrackUs/Trackus_iOS"
        
        static let PERSONAL_INFORMATION_PROCESSING_POLICY = "https://colorful-force-5d2.notion.site/a3c5eb465e464a4a85ec708f97e0201e?pvs=4"
        static let TERMS_OF_LOCATION_INFORMATION_SERVICE = "https://colorful-force-5d2.notion.site/TrackUs-be971d4c799c4c12ab9e984aeafedc1d?pvs=4"
    }
    
    enum UserDefaultKeys {
        static let blockedCourse = "blockedCourse"
    }

    enum FirebasePath {
        static let COLLECTION_UESRS = Firestore.firestore().collection("users")
        static let COLLECTION_RUNNING = Firestore.firestore().collection("running")
    }
}
