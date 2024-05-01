//
//  CourseDetailView.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/22.
//
// TODO: - 수정하기 기능구현
// - 현재 코스정보를 수정화면으로 넘기기
// - 수정하기 화면에서 데이터를 새롭게 덮어쓰기

import SwiftUI
import MapboxMaps

struct CourseDetailView: View {
    enum MenuValue: String, CaseIterable, Identifiable {
        var id: Self { self }
        
        case edit = "수정"
        case delete = "삭제"
        case block = "이 게시물을 보지 않기"
        case report = "신고하기"
    }
    
    private let authViewModel = AuthenticationViewModel.shared
    
    @State private var showingAlert = false
    
    @EnvironmentObject var router: Router
    @ObservedObject var userSearchViewModel: UserSearchViewModel
    @ObservedObject var courseViewModel: CourseViewModel
    
    var isOwner: Bool {
        courseViewModel.course.ownerUid == authViewModel.userInfo.uid
    }
    
    var isMember: Bool {
        courseViewModel.course.members.contains(authViewModel.userInfo.uid)
    }
    
    var isFullMember: Bool {
        courseViewModel.course.members.count >= courseViewModel.course.numberOfPeople
    }
    
    var reportStatus: Bool {
        courseViewModel.course.reportLog.contains(authViewModel.userInfo.uid)
    }
    
    var body: some View {
        VStack {
            MapboxMapView(
                mapStyle: .numberd,
                coordinates: courseViewModel.course.coordinates
            )
            .frame(height: 230)
            
            ScrollView {
                
                VStack(spacing: 0)   {
                    if reportStatus {
                        HStack {
                            Image(.sirenIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("신고 처리가 된 게시물입니다.")
                                .customFontStyle(.gray2_L14)
                            Spacer()
                        }     .padding(.top, 10)
                            .padding(.horizontal, 16)
                    }
                    
                    RunningStats(
                        estimatedTime: courseViewModel.course.estimatedTime,
                        calories: courseViewModel.course.estimatedCalorie,
                        distance: courseViewModel.course.coordinates.totalDistance
                    )
                    .padding(.top, 10)
                    .padding(.horizontal, 16)
                    
                    courseDetailLabels
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                    
                    memberList
                        .padding(.top, 20)
                        .padding(.leading, 16)
                }
                .padding(.bottom, 30)
            }
            VStack {
                if isFullMember && !isMember {
                    MainButton(active: false, buttonText: "해당 러닝은 마감되었습니다.") {}
                }
                else if !isMember {
                    MainButton(buttonText: "러닝 참가하기") {
                        courseViewModel.addMember()
                    }
                } else if isMember {
                    HStack {
                        MainButton(active: !isOwner, buttonText: "러닝 참가취소", buttonColor: .Caution) {
                            courseViewModel.removeMember()
                        }
                    }
                }
                
            }
            .padding(.horizontal, 16)
        }
        .customNavigation {
            NavigationText(title: "모집글 상세보기")
        } left: {
            NavigationBackButton()
        } right: {
            VStack {
                editMenu
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("알림"),
                message: Text("모집글이 삭제됩니다.\n해당 모집글을 삭제 하시겠습니까?"),
                primaryButton: .default (
                    Text("취소"),
                    action: { }
                ),
                secondaryButton: .destructive (
                    Text("삭제"),
                    action: {
                        courseViewModel.removeCourse {
                            router.popToRoot()
                        }
                    }
                )
            )
        }
    }
}

extension CourseDetailView {
    
    // 제목, 부가설명 등등
    var courseDetailLabels: some View {
        VStack {
            
            HStack {
                Text(courseViewModel.course.startDate?.formattedString() ?? Date().formatted())
                    .customFontStyle(.gray2_R12)
                Spacer()
                RunningStyleBadge(style: .init(rawValue: courseViewModel.course.runningStyle) ?? .running)
            }
            
            VStack(alignment: .leading) {
                Text(courseViewModel.course.title)
                    .customFontStyle(.gray1_B20)
                
                HStack(spacing: 10) {
                    HStack {
                        Image(.pinIcon)
                        
                        Text(courseViewModel.course.address)
                            .customFontStyle(.gray1_R12)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Image(.arrowBothIcon)
                        Text(courseViewModel.course.distance.asString(unit: .kilometer))
                            .customFontStyle(.gray1_R12)
                    }
                }
                
                Text(courseViewModel.course.content)
                    .customFontStyle(.gray1_R14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // 참여자 리스트
    
    var memberList: some View {
        VStack(alignment: .leading) {
            UserList(
                users: userSearchViewModel.filterdUserData(uid: courseViewModel.course.members),
                ownerUid: courseViewModel.course.ownerUid
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var editMenu: some View {
        Menu {
            ForEach(MenuValue.allCases) { menu in
                if menu == .edit && isOwner {
                    Button(action: editButtonTapped, label: {
                        Text(menu.rawValue)
                    })
                }
                if menu == .delete && isOwner {
                    Button(role: .destructive,action: deleteButtonTapped, label: {
                        Text(menu.rawValue)
                    })
                }
                if menu == .block && !isOwner {
                    Button(action: blockButtonTapped, label: {
                        Text(menu.rawValue)
                            .customFontStyle(.gray2_R16)
                    })
                }
                if menu == .report && !isOwner {
                    Button(role: .destructive, action: complainButtonTapped, label: {
                        Text(menu.rawValue)
                    }).disabled(reportStatus)
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(.black)
                .padding(15)
        }
    }
}

extension CourseDetailView {
    func editButtonTapped() {
        router.push(.courseRegister(courseViewModel))
    }
    
    func deleteButtonTapped() {
        showingAlert = true
    }
    
    func blockButtonTapped() {
        courseViewModel.blockCourse(uid: courseViewModel.course.uid)
        router.popToRoot()
    }
    
    func complainButtonTapped() {
        router.push(.courseReport(courseViewModel))
    }
}
