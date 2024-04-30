//
//  Router.swift
//  TrackUs
//
//  Created by 석기권 on 2024/01/30.
//

import SwiftUI



enum Tab {
    case running, chat, report, profile
    var tabName: String {
        switch self {
        case .chat:
            "채팅"
        case .profile:
            "프로필"
        case .report:
            "리포트"
        case .running:
            "러닝"
        }
    }
}

final class Router: ObservableObject {
    // MARK: - PAGE
    enum Page: Hashable {
        // Root
        case running
        case chat
        case report
        case profile
        // Profile
        case profileEdit
        case runningRecorded
        case faq
        case setting
        case withDrawal
        // Home
        case runningSelect(CourseListViewModel, UserSearchViewModel)
        case runningStart(RunActivityViewModel)
        case runningResult(RunActivityViewModel)
        case courseDrawing
        case courseDetail(CourseViewModel)
        case courseRegister(CourseViewModel)
        // Chat
        case chatting(ChatViewModel)
        // Report
        case recordDetail(Runninglog)
        // UserProfileView
        case userProfile(String)
        case userReport(String)
        case trackusIntro
        case blockedMgmt
        case courseReport(CourseViewModel)
    }

    // MARK: - FULL SCREEN
    enum FullScreenCover: String, Identifiable {
        case payment
        
        var id: String {
            self.rawValue
        }
    }

    // MARK: - SHEET
    enum Sheet: Hashable, Identifiable {
        static func == (lhs: Sheet, rhs: Sheet) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        case webView(url: String)
        
        var id: String {
            String(describing: self)
        }
    }
    
    @Published var path = NavigationPath()
    @Published var selectedIndex: Tab = .running
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    @MainActor
    func push(_ page: Page) {
        path.append(page)
    }

    @MainActor
    func pushOverRootView(_ page: Page) {
        path = NavigationPath()
        path.append(page)
    }
    
    @MainActor
    func pop() {
        if path.count != 0 {
            path.removeLast()
        }
    }
    
    @MainActor
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @MainActor
    func present(sheet: Sheet) {
        self.sheet = sheet
    }
    
    @MainActor
    func present(fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }
    
    @MainActor
    func dismissSheet() {
        self.sheet = nil
    }
    
    @MainActor
    func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
    
    @ViewBuilder
    func buildScreen(page: Page) -> some View {
        switch page {
        case .running:
            RunningHomeView()
        case .chat:
            ChatListView()
        case .report:
            ReportView()
        case .profile:
            MyProfileView()
        case .profileEdit:
            ProfileEditView()
        case .runningRecorded:
            RunningRecordView()
        case .courseDetail(let courseViewModel):
            CourseDetailView(courseViewModel: courseViewModel)
        case .courseDrawing:
            CourseDrawingView()
        case .courseRegister(let courseViewModel):
            CourseRegisterView(courseViewModel: courseViewModel)
        case .faq:
            FAQView()
        case .setting:
            SettingsView()
        case .withDrawal:
            Withdrawal()
        case .runningSelect(let courseListViewModel, let userSearchViewModel):
            RunningSelectView(courseListViewModel: courseListViewModel, userSearchViewModel: userSearchViewModel)
        case .runningStart(let runViewModel):
            RunningStartView(runViewModel: runViewModel)
        case .runningResult(let runViewModel):
            RunningResultView(runViewModel: runViewModel)
        case .recordDetail(let myRecord):
            MyRecordDetailView(runningLog: myRecord)
        case .userProfile(let userId):
            UserProfileView(userUid: userId)
        case .chatting(let chatViewModel):
            ChattingView(chatViewModel: chatViewModel)
        case .userReport(let userId):
            UserReportView(userUid: userId)
        case .trackusIntro:
            TeamIntroView()
        case .blockedMgmt:
            BlockedContentsMgmtView()
        case .courseReport(let courseVM):
            CourseReportView(courseVM: courseVM)
        }
    }
    
    @ViewBuilder
    func buildScreen(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
        case .payment:
            PremiumPaymentView()
        }
    }
    
    @ViewBuilder
    func buildScreen(sheet: Sheet) -> some View {
        switch sheet {
        case .webView(url: let url):
            WebViewSurport(url: url)
        }
    }
}

extension Router.Page {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Router.Page, rhs: Router.Page) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var id: String {
        String(describing: self)
    }
}
