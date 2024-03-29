//
//  String+.swift
//  TrackUs
//
//  Created by 석기권 on 3/29/24.
//

import Foundation

extension String {
    /// 문자열 자르기
    func subString(count: Int) -> String {
        guard self.count > count else {
            return self
        }
        let startIndex = self.index(self.startIndex, offsetBy: 0)
        let endIndex = self.index(self.startIndex, offsetBy: count)
        let slicedString = self[startIndex..<endIndex]
        return String("\(slicedString)...")
    }
}
