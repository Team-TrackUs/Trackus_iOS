//
//  RunningHomeView.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/04.
//

import SwiftUI
import Kingfisher
import PopupView
@_spi(Experimental) import MapboxMaps

struct RunningHomeView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var courseListViewModel: CourseListViewModel
    
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @StateObject var userSearchViewModel = UserSearchViewModel()
    
    @State private var viewport: Viewport = .followPuck(zoom: 13, bearing: .constant(0))
    @State private var isOpen: Bool = false
    @State private var showingPopup: Bool = false
    @State private var showingAlert: Bool = false
    @State private var offset: CGFloat = 0
    @State private var deltaY: CGFloat = 0
    
    let cheeringPhrase = [
        "나만의 페이스로, 나만의 피니쉬라인까지.",
        "걸음마다 성장이 느껴지는 곳, 함께 뛰어요!",
        "새로운 기회는 당신의 발 아래에 있어요.",
        "나만의 런웨이에서 뛰어보세요."
    ].randomElement()!
    
    private var isFocusingUser: Bool {
        return viewport.followPuck?.bearing == .constant(0)
    }
    
    private var isFollowingUser: Bool {
        return viewport.followPuck?.bearing == .heading
    }
}

// MARK: - View
extension RunningHomeView {
    var body: some View {
        GeometryReader { geometry in
            Map(viewport: $viewport) {
                Puck2D(bearing: .heading)
            }
            
            .mapStyle(.init(uri: StyleURI(rawValue: "mapbox://styles/seokki/clslt5i0700m901r64bli645z") ?? .light))
            .onTapGesture {
                withAnimation {
                    isOpen = false
                }
                offset = 0
            }
            
            .overlay(alignment: .bottomTrailing, content: {
                addCourseButton
                    .padding(16)
            })
            .frame(height: geometry.size.height - 95)
            .offset(y: min(offset, 0))
            .animation(.interactiveSpring(), value: offset)
            
            // MARK: - Sheet
            BottomSheet(isOpen: $isOpen, maxHeight: 510, minHeight: 100) {
                VStack(spacing: 20) {
                    
                    // 프로필 & 러닝시작
                    profileHeader
                        .padding(.horizontal, 16)
                    
                    // 내주변 러닝메이트
                    runningAroundMe
                  
                }
            } onChanged: { gestureValue in
                let newDeltaY = gestureValue.translation.height
                let deltaHeight = abs(abs(newDeltaY) - abs(deltaY))
                let endPoint = geometry.size.height * 0.3 // 3분의 1을 넘어가는 지점에서 종료
                
                if newDeltaY < deltaY && offset > -endPoint  {
                    offset -=  deltaHeight
                } else if newDeltaY > deltaY {
                    offset += deltaHeight
                }
                
                deltaY = gestureValue.translation.height
                
            } onEnded: { _ in
                let endPoint = geometry.size.height * 0.3
                
                if isOpen {
                    offset = -endPoint
                } else {
                    offset = 0
                }
                deltaY = 0
            }
            
        }
        .overlay(alignment: .topTrailing) {
            locationMeButton
                .padding(.top, UIApplication.shared.statusBarFrame.height)
        }
        .onAppear {
            courseListViewModel.fetchCourseData()
            
            Task {
                await HealthKitService.requestAuthorization()
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - SubView's
extension RunningHomeView {
    // 프로필 헤더
    var profileHeader: some View {
        VStack {
            HStack {
                KFImage(URL(string: authViewModel.userInfo.profileImageUrl ?? ""))
                    .placeholder({ProgressView()})
                    .onFailureImage(KFCrossPlatformImage(named: "profile_img"))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("\(authViewModel.userInfo.username.subString(count: 10))님!")
                        .customFontStyle(.gray1_B16)
                    
                    Text(cheeringPhrase)
                        .customFontStyle(.gray1_R12)
                }
                
                Spacer()
                
                Button(action: startButtonTapped, label: {
                    Text("러닝 시작")
                        .foregroundStyle(.white)
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                })
                .background(.main)
                .clipShape(Capsule())
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("러닝을 시작하기 위해서 앱에서 위치를 엑세스할 수 있도록 허용해 주세요."),
                        message: Text("러닝을 추적하고 그 외 다른 서비스와 기능을 이용하기 위해서 정확한 위치 정보가 필요합니다."),
                        primaryButton: .destructive (
                            Text("취소"),
                            action: { }
                        ),
                        secondaryButton: .default (
                            Text("설정"),
                            action: {
                                if let appSettings = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
                                    UIApplication.shared.open(appSettings,options: [:],completionHandler: nil)
                                }
                            }
                        )
                    )
                }
                .popup(isPresented: $showingPopup) {
                    HealthSettingPopup(isShowing: $showingPopup)
                } customize: {
                    $0
                        .isOpaque(true)
                        .dragToDismiss(false)
                        .closeOnTap(false)
                }
            }
            .padding(.vertical, 10)
            Divider()
                .background(.divider)
        }
    }
    
    // 내주변 러닝
    var runningAroundMe: some View {
        VStack(spacing: 16) {
            HStack {
                Image(.fire3DImg)
                    .resizable()
                    .frame(width: 38, height: 38)
                
                VStack(alignment: .leading) {
                    Text("혼자 하는 러닝이 지루하다면?")
                        .customFontStyle(.gray1_B16)
                    
                    Text("내 근처 러닝메이트와 함께 러닝을 진행해보세요!")
                        .customFontStyle(.gray1_R12)
                }
                .padding(.leading, 8)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // 가로 스크롤
            if !courseListViewModel.courseList.isEmpty, authViewModel.userInfo.uid != "" {
             
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack {
                        HStack(spacing: 12) {
                            ForEach(courseListViewModel.courseFromUnBlockList, id: \.self) { course in
                                
                                Button(action: {
                                    router.push(.courseDetail(CourseViewModel(course: course)))
                                }, label: {
                                    if let user =  userSearchViewModel.filterdUserData(uid: [course.ownerUid]).first {
                                        RunningCell(course: course, user: userSearchViewModel.filterdUserData(uid: [user.uid])[0])
                                    } else {
                                        RunningCell(course: course)
                                    }
                                })
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.leading, 16)
            } else {
                PlaceholderView(
                    title: "근처 러닝 모임이 존재하지 않습니다.",
                    message: "러닝 메이트 모집 기능을 통해 직접 러닝 모임을 만들어보세요!",
                    maxHeight: 300
                )
            }
            
        }
    }
    
    var addCourseButton: some View {
        Button(action: {
            router.push(.courseDrawing)
        }, label: {
            Circle()
                .frame(width: 52, height: 52)
                .foregroundColor(.main)
                .overlay (
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                )
        })
    }
    
    var locationMeButton: some View {
        Button(action: {
            withViewportAnimation(.default(maxDuration: 1)) {
                if isFocusingUser {
                    viewport = .followPuck(zoom: 16.5, bearing: .heading, pitch: 60)
                } else if isFollowingUser {
                    viewport = .idle
                } else {
                    viewport = .followPuck(zoom: 13, bearing: .constant(0))
                }
            }
        }, label: {
            Image(.locationIcon)
        })
    }
    
    func getMessage() {
        
    }
}

// MARK: - Method's
extension RunningHomeView {
    private func startButtonTapped() {
        Task {
            let dataAvailable = await HealthKitService().checkReadTypePersmission()
            
            if !dataAvailable {
                showingPopup = true
            }
            else if !LocationService.locationServicesEnabled() {
                showingAlert = true
            } else {
                router.push(.runningSelect(courseListViewModel, userSearchViewModel))
            }
        }
    }
}

struct HealthSettingPopup: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("건강데이터")
                    .customFontStyle(.gray1_B20)
                
                VStack(spacing: 10) {
                    Image(.heartImg)
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    Text("운동정보 추적을 위해서 건강데이터 접근 권한이 필요합니다.")
                        .multilineTextAlignment(.center)
                        .customFontStyle(.gray2_R14)
                        .frame(width: 230)
                }
                
                
                Button(action: {
                    if let appSettings = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
                        UIApplication.shared.open(appSettings,options: [:],completionHandler: nil)
                    }
                }, label: {
                    Text("설정으로 이동")
                        .customFontStyle(.main_R16)
                        .frame(minHeight: 40)
                        .padding(.horizontal, 20)
                        .overlay(Capsule().stroke(.main))
                })
                .frame(width: 230)
                
                Button(action: {
                    isShowing = false
                }, label: {
                    Text("닫기")
                        .customFontStyle(.gray1_B16)
                })
            }
            .padding(20)
        }
        .padding(20)
        .background(.white)
        .cornerRadius(12)
    }
}
