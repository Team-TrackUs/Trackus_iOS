//
//  Debug.swift
//  TrackUs
//
//  Created by 석기권 on 4/5/24.
//

import Foundation

public func debugPrint(_ object: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    let string = object.reduce("") { $0.isEmpty ? "\($1)" : "\($0)\(separator)\($1)" }
    Swift.print(string, separator: separator, terminator: terminator)
    #endif
}

public func debugPrint(_ object: Any, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(object, separator: separator, terminator: terminator)
    #endif
}
