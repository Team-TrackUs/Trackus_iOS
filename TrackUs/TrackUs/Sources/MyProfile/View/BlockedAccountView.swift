//
//  BlockedAccountView.swift
//  TrackUs
//
//  Created by 박소희 on 5/2/24.
//

import SwiftUI

struct BlockedAccountView: View {
    @EnvironmentObject var router: Router
    @ObservedObject var authenticationViewModel = AuthenticationViewModel.shared
    
    @State private var blockedUserInfoList: [(username: String, profileImageUrl: String?, uid: String)] = []
    
    var body: some View {
        ScrollView {
            VStack {
                if blockedUserInfoList.isEmpty {
                    Text("차단된 계정이 없습니다.")
                        .customFontStyle(.gray1_B16)
                        .padding()
                } else {
                    ForEach(blockedUserInfoList, id: \.uid) { userInfo in
                        HStack {
                            if let profileImageUrl = userInfo.profileImageUrl {
                                Button {
                                    router.push(.userProfile(userInfo.uid))
                                } label: {
                                    AsyncImage(url: URL(string: profileImageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .padding(.trailing, 10)
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .padding(.trailing, 10)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .padding(.trailing, 10)
                            }
                            
                            Text(userInfo.username)
                                .customFontStyle(.gray1_R16)
                            
                            Spacer()

                            Button(action: {
                                unblockUser(withUID: userInfo.uid)
                                blockedUserInfoList.removeAll { $0.uid == userInfo.uid }
                            }) {
                                Text("차단 해제")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.Main)
                                    )
                                
                            }
                        }
                        Divider()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        
        .onAppear {
            blockedUserInfoList = authenticationViewModel.userInfo.blockedUserList?.compactMap { uid in
                guard let username = authenticationViewModel.userInfo.blockedUserList?.first(where: { $0 == uid }) else {
                    return nil
                }
                return (username: username, profileImageUrl: nil, uid: uid)
            } ?? []
            
            for (index, userInfo) in blockedUserInfoList.enumerated() {
                authenticationViewModel.getUserInfo(uid: userInfo.uid) { username, profileImageUrl in
                    if let username = username {
                        blockedUserInfoList[index].username = username
                        blockedUserInfoList[index].profileImageUrl = profileImageUrl
                    }
                }
            }
        }
        .customNavigation {
            Text("차단된 계정")
                .customFontStyle(.gray1_SB16)
        } left: {
            NavigationBackButton()
        }
    }
    
    private func unblockUser(withUID uid: String) {
        authenticationViewModel.UnblockingUser(uid: uid)
    }
}
