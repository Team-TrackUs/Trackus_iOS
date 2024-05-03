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
    
    // 차단된 경우 alert용
    @State var blockedAlert: Bool = false
    // 차단여부 확인용
    @State var blockAlert: Bool = false
    @State private var sideMenuPresented = false
    
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
            // 현재 채팅방 초기화, Notification용도
            ChatListViewModel.shared.currentChatRoom = ""
        }
        .customNavigation {
            NavigationText(title: "프로필 확인")
        } left: {
            NavigationBackButton()
        } right: {
            Menu("", systemImage: "ellipsis") {
                if userViewModel.otherUserInfo.uid != authViewModel.userInfo.uid {
                    Button(role: .destructive) {
                        blockAlert.toggle()
                    } label: {
                        Label(authViewModel.checkBlocking(uid: userViewModel.otherUserInfo.uid) ? "차단 해제" : "차단하기", systemImage: "person.slash")
                    }
                    Button {
                        router.push(.userReport(userUid))
                    } label: {
                        Label("신고하기", systemImage: "exclamationmark.circle")
                    }
                } else {
                    Button {
                        router.push(.profileEdit)
                    } label: {
                        Label("프로필 편집", systemImage: "square.and.pencil")
                    }
                }
                
                Button("취소", action: {})
            }
            .foregroundStyle(.gray1)
        }
        .alert(Text(authViewModel.checkBlocking(uid: userViewModel.otherUserInfo.uid) ? "차단 해제" : "차단 하기") , isPresented: $blockAlert) {
            Button("취소", role: .cancel) { }
            Button(role: .destructive) {
                
                if authViewModel.checkBlocking(uid: userViewModel.otherUserInfo.uid){
                    // 차단 해제
                    authViewModel.UnblockingUser(uid: userViewModel.otherUserInfo.uid)
                }else{
                    // 차단 등록
                    authViewModel.BlockingUser(uid: userViewModel.otherUserInfo.uid)
                }
            } label: {
                Text(authViewModel.checkBlocking(uid: userViewModel.otherUserInfo.uid) ? "차단 해제" : "차단 하기")
            }
        } message: {
            Text(authViewModel.checkBlocking(uid: userViewModel.otherUserInfo.uid) ? "\(userViewModel.otherUserInfo.username)님 차단을 해제하시겠습니까?" :
                    "\(userViewModel.otherUserInfo.username)님을 차단하시겠습니까?")
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
    // 차단된 경우 alert용
    @State var blockedAlert: Bool = false
    // 차단여부 확인용
    @State var blockAlert: Bool = false
    @State private var reportAlert = false
    
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
                if userInfo.uid != authViewModel.userInfo.uid {
                    VStack {
                        // 채팅 버튼
                        Button {
                            if authViewModel.userInfo.reportIDList?.count ?? 0 >= 3{
                                // 신고 누적 횟수 3회 초과
                                reportAlert.toggle()
                            }else if authViewModel.userInfo.blockList.contains (userUid){
                                // 사용자 차단 여부 확인
                                blockedAlert.toggle()
                            }else {
                                router.push(.chatting(ChatViewModel(myInfo: authViewModel.userInfo, opponentInfo: userInfo)))
                            }
                        } label: {
                            Image(systemName: authViewModel.userInfo.blockList.contains(userUid) ? "exclamationmark.bubble" : "bubble")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.gray1)
                        }
                        
                        Text("1:1 대화")
                            .customFontStyle(.gray2_R12)
                    }
                    .padding(.top, 16)
                    .alert("채팅 불가",
                           isPresented: $blockedAlert) {
                        Button("확인", role: .cancel) {}
                    } message: {
                        Text("차단된 사용자입니다.")
                    }
                    .alert("채팅 제한",
                           isPresented: $reportAlert) {
                        Button("확인", role: .cancel) {}
                    } message: {
                        Text("신고로 인해 채팅이 일시 제한되었습니다.\n\n자세한 내용은 아래 메일을 통해\n문의해주시기 바랍니다.\nteam.trackus@gmail.com")
                    }
                }
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
