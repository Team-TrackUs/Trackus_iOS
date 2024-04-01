//
//  RunningSelectView.swift
//  TrackUs
//
//  Created by 박선구 on 2/23/24.
//

import SwiftUI
import Kingfisher
import PopupView

struct RunningSelectView: View {
    @State var isSelect: Int?
    @State var seletedID: String = ""
    @State private var isPersonal: Bool = false
    @State private var showingPopup: Bool = false
    
    @EnvironmentObject var router: Router
    @ObservedObject var courseListViewModel: CourseListViewModel
    @ObservedObject var userSearchViewModel: UserSearchViewModel
    
    var vGridItems = [GridItem()]
    
    var buttonEnabled: Bool {
        isPersonal || !seletedID.isEmpty
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("러닝 시작하기")
                        .customFontStyle(.gray1_B24)
                    
                    Spacer()
                }
                Text("원하는 러닝 타입을 선택하신 뒤 러닝 시작 버튼을 눌러주세요")
                    .customFontStyle(.gray2_R15)
                
                Text("참여 러닝 모임 리스트")
                    .customFontStyle(.gray1_SB17)
                    .padding(.top, 37)
            }
            .padding(.horizontal, 16)
            
            ZStack {
                VStack {
                    let myCourse = courseListViewModel.myCourseData
                    if !myCourse.isEmpty {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: vGridItems, spacing: 8) {
                                ForEach(myCourse, id: \.self) { course in
                                    Button {
                                        let isSeletedSameItem = seletedID == course.uid
                                        if isSeletedSameItem {
                                            seletedID = ""
                                        } else {
                                            seletedID = course.uid
                                        }
                                        
                                    } label: {
                                        let isSelectedNow = !seletedID.isEmpty
                                        let seleted = seletedID == course.uid
                                        if let user = userSearchViewModel.findUserWithUID(course.ownerUid) {
                                            selectedCell(isSelect: isSelectedNow ? seleted : false, course: course, user: user)
                                        }
                                    }
                                }
                            }
                            
                        }
                    } else {
                        PlaceholderView(
                            title: "참여중인 러닝이 존재하지 않습니다.",
                            message: "러닝 메이트 모집 기능을 통해 직접 러닝 모임을 만들어보세요!",
                            maxHeight: .infinity
                        )
                    }
                }
                .padding(16)
                .blur(radius: isPersonal ? 3 : 0)
                .disabled(isPersonal ? true : false)
            }
            
            VStack {
                Button {
                    isPersonal.toggle()
                } label: {
                    HStack(spacing: 8){
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(.main.opacity(isPersonal ? 1 : 0))
                            .padding(4)
                            .overlay(
                                Circle()
                                    .stroke(.gray3, lineWidth: 1)
                            )
                        Text("개인 러닝 모드")
                            .customFontStyle(.gray1_R12)
                    }
                    .animation(.easeIn(duration: 0.3), value: isPersonal)
                }
                .padding(.vertical, 8)
                
                MainButton(active: buttonEnabled, buttonText: "러닝 시작") {
                    if isPersonal {
                        showingPopup.toggle()
                    } else if !seletedID.isEmpty {
                        if let seletedItem = courseListViewModel.findCourseWithUID(seletedID) {
                            router.push(.runningStart)
                        }
                        
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .popup(isPresented: $showingPopup) {
            SettingPopup(
                showingPopup: $showingPopup,
                settingVM: SettingPopupViewModel()
            )
        } customize: {
            $0
                .backgroundColor(.black.opacity(0.3))
                .isOpaque(true)
                .dragToDismiss(false)
                .closeOnTap(false)
        }
        .customNavigation {
            NavigationText(title: "러닝 시작하기")
        } left: {
            NavigationBackButton()
        }
    }
}

struct selectedCell: View {
    var isSelect: Bool
    let course: Course
    let user: UserInfo
    
    var body: some View {
        HStack(alignment: .center) {
            KFImage(URL(string: course.routeImageUrl))
                .resizable()
                .frame(width: 75, height: 75)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(course.title)
                        .bold()
                        .customFontStyle(.gray1_R14)
                    
                    Spacer()
                    
                    RunningStyleBadge(style: .init(rawValue: course.runningStyle) ?? .walking)
                }
                
                HStack {
                    HStack {
                        Image(.pinIcon)
                        Text(course.address)
                            .customFontStyle(.gray1_R9)
                    }
                    
                    HStack {
                        Image(.arrowBothIcon)
                        Text(course.distance.asString(unit: .kilometer))
                            .customFontStyle(.gray1_R9)
                    }
                }
                
                HStack {
                    HStack {
                        KFImage(URL(string: user.profileImageUrl ?? ""))
                            .placeholder({ProgressView()})
                            .onFailureImage(KFCrossPlatformImage(named: "profile_img"))
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.vertical, 12)
                            .clipShape(Circle())
                        Text(user.username)
                            .customFontStyle(.gray2_R12)
                        Image(.crownIcon)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .resizable()
                            .frame(width: 15, height: 12)
                            .foregroundColor(.gray1)
                        
                        Text("\(course.members.count)/\(course.numberOfPeople)")
                            .customFontStyle(.gray1_M16)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelect ? .main : .gray3, lineWidth: 4)
        )
        .cornerRadius(12)
        
    }
}

