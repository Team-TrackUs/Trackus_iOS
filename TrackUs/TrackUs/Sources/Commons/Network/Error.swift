//
//  Error.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation

enum ErrorType: Error {
    case firebaseError
    
    var message: String {
        switch self {
        case .firebaseError:
            "firebase 에러"
        }
    }
}
