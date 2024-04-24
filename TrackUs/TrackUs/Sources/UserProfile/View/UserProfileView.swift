//
//  UserProfileView.swift
//  TrackUs
//
//  Created by 윤준성 on 2/18/24.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var router: Router
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @ObservedObject var userViewModel = UserProfileViewModel.shared
    @State private var selectedImage: Image?
    @State private var selectedDate: Date?
    let userUid: String
    
    init(userUid: String) {
        self.userUid = userUid
    }
    
    var body: some View {
        ScrollView {
            UserProfileContent(userInfo: userViewModel.otherUserInfo, selectedDate: $selectedDate, userProfileViewModel: userViewModel, userUid: userUid)
        }
        .onAppear {
            userViewModel.getOtherUserInfo(for: userUid)
            userViewModel.fetchUserLog(userId: userUid) {
                print(userViewModel.runningLog)
            }
        }
        .customNavigation {
            NavigationText(title: "프로필 확인")
        } left: {
            NavigationBackButton()
        }
    }
}

struct UserProfileContent: View {
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @EnvironmentObject var router: Router
    let userInfo: UserInfo
    @Binding var selectedDate: Date?
    @ObservedObject var userProfileViewModel: UserProfileViewModel
    let userUid : String
    // 차단 여부
    
    var body: some View {
        VStack {
            // 프로필 헤더
            VStack {
                if let image = userInfo.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 116, height: 116)
                        .padding(.vertical, 12)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                } else {
                    Image(.profileImg)
                        .resizable()
                        .frame(width: 116, height: 116)
                        .padding(.vertical, 12)
                        .clipShape(Circle())
                }
            }
            
            Text("\(userInfo.username)님")
                .customFontStyle(.gray1_SB16)
            
            HStack {
                if userInfo.isProfilePublic {
                    if let height = userInfo.height,
                       let weight = userInfo.weight,
                       let age = userInfo.age {
                        Text("\(height)cm · \(weight)kg · \(age)대")
                            .customFontStyle(.gray2_R16)
                    } else {
                        Text("신체 정보가 없습니다.")
                            .customFontStyle(.gray2_R16)
                    }
                } else {
                    Text("프로필 비공개 유저입니다.")
                        .customFontStyle(.gray2_R12)
                }
            }
            
            VStack {
                HStack(spacing: 63) {
                    if userInfo.uid != authViewModel.userInfo.uid {
                        VStack {
                            // 채팅 버튼
                            Button {
                                router.push(.chatting(ChatViewModel(myInfo: authViewModel.userInfo, opponentInfo: userInfo)))
                            } label: {
                                Image(systemName: "bubble")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.gray1)
                            }
                            
                            Text("1:1 대화")
                                .customFontStyle(.gray2_R12)
                        }
                        
                        VStack {
                            // 차단 버튼
                            Button {
                                // 차단하기 기능
                                if authViewModel.checkBlocking(uid: userInfo.uid){
                                    // 차단 해제
                                    authViewModel.UnblockingUser(uid: userInfo.uid)
                                }else{
                                    // 차단 등록
                                    authViewModel.BlockingUser(uid: userInfo.uid)
                                }
                            } label: {
                                Image(systemName: "person.slash")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.gray1)
                            }
                            
                            Text(authViewModel.checkBlocking(uid: userInfo.uid) ? "차단 해제" : "차단")
                                .customFontStyle(.gray2_R12)
                        }
                        
                        VStack {
                            // 신고 버튼
                            Button {
                                router.push(.userReport(userUid))
                            } label: {
                                Image(systemName: "exclamationmark.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.caution)
                            }
                            
                            Text("신고")
                                .customFontStyle(.gray2_R12)
                        }
                    }
                }
                .padding(.top, 12)
            }
            .padding(.bottom, 15)
        }
        .padding(.bottom, 32)
        
        Spacer()
        
        if userInfo.isProfilePublic {
            switch userProfileViewModel.userLogLoadingState {
            case .loading:
                OtherUserRecordView(selectedDate: $selectedDate, userInfo: userProfileViewModel.otherUserInfo, runningLog: userProfileViewModel.runningLog)
                    .padding(.top, -40)
                    .redacted(reason: .placeholder)
            case .loaded:
                OtherUserRecordView(selectedDate: $selectedDate, userInfo: userProfileViewModel.otherUserInfo, runningLog: userProfileViewModel.runningLog)
                    .padding(.top, -40)
            case .error(_) :
                Text("ERROR")
            }
        } else {
            PrivateUserView()
                .padding()
        }
    }
}


#Preview {
    UserProfileView(userUid: "")
}
