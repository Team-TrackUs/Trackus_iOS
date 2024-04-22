//
//  MainTabView.swift
//  TrackUs
//
//  Created by 석기권 on 2024/01/30.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var router: Router
    @StateObject var chatViewModel = ChatListViewModel.shared
    @State private var selectedTab: Tab = .running
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.shadowColor = .divider
        appearance.backgroundColor = UIColor.white
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack{
                TabView(selection: $router.selectedIndex) {
                    VStack {
                        router.buildScreen(page: .running)
                    }
                    .tabItem {
                        Image(.runIcon)
                            .renderingMode(.template)
                        Text(Tab.running.tabName)
                    }
                    .tag(Tab.running)
                    
                    router.buildScreen(page: .chat)
                        .tabItem {
                            Image(.chattingIcon)
                                .renderingMode(.template)
                            Text(Tab.chat.tabName)
                        }
                        .tag(Tab.chat)
                    
                    router.buildScreen(page: .report)
                        .tabItem {
                            Image(.reportIcon)
                                .renderingMode(.template)
                            Text(Tab.report.tabName)
                        }
                        .tag(Tab.report)
                    
                    
                    router.buildScreen(page: .profile)
                        .tabItem {
                            Image(.profileIcon)
                                .renderingMode(.template)
                            Text(Tab.profile.tabName)
                        }
                        .tag(Tab.profile)
                }
                .navigationDestination(for: Router.Page.self, destination: { page in
                    router.buildScreen(page: page)
                })
                .sheet(item: $router.sheet, content: { sheet in
                    router.buildScreen(sheet: sheet)
                })
                .fullScreenCover(item: $router.fullScreenCover, content: { fullScreenCover in
                    router.buildScreen(fullScreenCover: fullScreenCover)
                })
                
                .onChange(of: router.selectedIndex) { _ in
                    HapticManager.instance.impact(style: .light)
                }
                GeometryReader { geometry in
                    if chatViewModel.updateNewMessage() != 0 {
                        VStack{
                            Spacer()
                            Text(chatViewModel.updateNewMessage() < 1000 ? "\(chatViewModel.updateNewMessage())" : "999+")
                                .foregroundStyle(.white)
                                .font(.system(size: 10, weight: .regular))
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                                .background(
                                    Capsule()
                                        .foregroundStyle(.caution)
                                )
                            //Text를 탭바 중간에서 오른쪽으로 2/4 위치에 배치
                                .offset(x: geometry.size.width * 1.5 / 4, y: -30)
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    MainTabView()
//}
