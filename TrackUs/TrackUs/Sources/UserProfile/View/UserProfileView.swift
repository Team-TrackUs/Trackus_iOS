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
    @StateObject var userProfileViewModel = UserProfileViewModel()
    @State private var selectedImage: Image?
    @State private var selectedDate: Date?
    let userUid: String
    
    init(userUid: String) {
        self.userUid = userUid
    }
    
    var body: some View {
        VStack {
            if userProfileViewModel.otherUserInfo != nil {
                UserProfileContent(userInfo: userProfileViewModel.otherUserInfo, selectedDate: $selectedDate)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            userProfileViewModel.getOtherUserInfo(for: userUid)
        }
        .customNavigation {
            NavigationText(title: "프로필 확인")
        } left: {
            NavigationBackButton()
        }
    }
}

struct UserProfileContent: View {
    let userInfo: UserInfo
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack {
            // 프로필 헤더
            VStack {
                if userInfo.isProfilePublic {
                    if let image = userInfo.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 116, height: 116)
                            .padding(.vertical, 12)
                            .clipShape(Circle())
                            .shadow(radius: 1)
                    } else {
                        Image(.profileDefault)
                            .resizable()
                            .frame(width: 116, height: 116)
                            .padding(.vertical, 12)
                            .clipShape(Circle())
                    }
                } else {
                    Image(.profileDefault)
                        .resizable()
                        .frame(width: 116, height: 116)
                        .padding(.vertical, 12)
                        .clipShape(Circle())
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
                    HStack {
                        Button(action: {
                            // 1:1 채팅방으로 이동해야함!
                        }) {
                            Text("1:1 대화")
                                .frame(width: 113, height: 28)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(26)
                        }
                        .padding(.top, 12)
                        
                        Button(action: {
                            // 신고하기 화면으로 이동해야함!
                        }) {
                            Text("신고하기")
                                .frame(width: 113, height: 28)
                                .background(Color.red)
                                .customFontStyle(.white_M14)
                                .foregroundColor(.white)
                                .cornerRadius(26)
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .padding(.bottom, 32)
            
            Spacer()
            
            if userInfo.isProfilePublic {
                MyRecordView(selectedDate: $selectedDate, showTrackUsProButton: false)
                    .padding(.top, -40)
            } else {
                PrivateUserView()
                    .padding()
            }
        }
    }
}

#Preview {
    UserProfileView(userUid: "")
}
