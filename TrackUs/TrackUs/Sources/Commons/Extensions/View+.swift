//
//  View+.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/21.
//

import SwiftUI

extension View {
    /// 로딩뷰 표시
    func presentLoadingView(status: Bool) -> some View {
        modifier(LoadingModifier(loadingStatus: status))
    }
    
    /// radius 설정
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
          clipShape( RoundedCorner(radius: radius, corners: corners) )
      }
    
    /// 제스쳐 비활성화
    func preventGesture() -> some View {
        modifier(PreventionGestureModifier())
    }
    
    /// 키보드 나타내기
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
}

extension View {
    
    /// 커스텀 네비게이션 View extension 메서드 입니다.
    /// - Parameters:
    ///   - center: View(필수)
    ///   - left: View
    ///   - right: View
    /// - Returns: View
    func customNavigation<C, L, R> (
        center: @escaping (() -> C),
        left: @escaping (() -> L),
        right: @escaping (() -> R)
    ) -> some View where C: View, L: View, R: View {
        modifier(CustomNavigationBarModifier(center: center, left: left, right: right))
    }
    
    /// 커스텀 네비게이션 View extension 메서드 입니다.
    /// - Parameters:
    ///   - center: View(필수)
    ///   - right: View
    /// - Returns: View
    func customNavigation<C, R> (
        center: @escaping (() -> C),
        right: @escaping (() -> R)
    ) -> some View where C: View, R: View {
        modifier(CustomNavigationBarModifier(center: center, right: right))
    }
    
    /// 커스텀 네비게이션 View extension 메서드 입니다.
    /// - Parameters:
    ///   - center: View(필수)
    ///   - left: View
    /// - Returns: View
    func customNavigation<C, L> (
        center: @escaping (() -> C),
        left: @escaping (() -> L)
    ) -> some View where C: View, L: View {
        modifier(CustomNavigationBarModifier(center: center, left: left))
    }
    
    /// 커스텀 네비게이션 View extension 메서드 입니다.
    /// - Parameters:
    ///   - center: View(필수)
    /// - Returns: View
    func customNavigation<C> (
        center: @escaping (() -> C)
    ) -> some View where C: View {
        modifier(CustomNavigationBarModifier(center: center))
    }
    
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
