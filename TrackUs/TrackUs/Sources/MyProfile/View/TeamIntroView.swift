//
//  TeamIntroView.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/01.
//

import SwiftUI

struct TeamIntroView: View {
    @EnvironmentObject var router: Router
    var gridItems = [GridItem(), GridItem()]
    @State var memberData = [
        TrackUsMember(name: "Sohee Park", image: "parkSohee_img", isDesigner: false),
        TrackUsMember(name: "Seokki Kwon", image: "kwonSeokki_img", isDesigner: false),
        TrackUsMember(name: "Juwon Choe", image: "choeJuwon_img", isDesigner: false),
        TrackUsMember(name: "Junseong Yoon", image: "yoonJunseong_img", isDesigner: false),
        TrackUsMember(name: "Seonkoo Park", image: "parkSeonKoo_img", isDesigner: false),
        TrackUsMember(name: "Jihoon Jeong", image: "jeongJihoon_img", isDesigner: true)
    ]
    
    var body: some View {
            ScrollView {
                VStack {
                    HStack {
                        Text("팀 트랙어스")
                            .customFontStyle(.gray1_B24)
                        
                        Spacer()
                    }
                    VStack {
                        HStack(spacing: 20) {
                            Image(.profileImg)
                                .cornerRadius(14)
                                .shadow(radius: 4)
                            
                            VStack {
                                Text("오늘부터\n").foregroundColor(.gray1) +
                                Text("내 주변 러너들").foregroundColor(.main) +
                                Text("과\n").foregroundColor(.gray1) +
                                Text("함께 ").foregroundColor(.main) +
                                Text("뛰어요!").foregroundColor(.gray1)
                            }
                            .font(.system(size: 24))
                            .bold()
                            
                        }
                        .padding(.vertical)
                        
                        Divider()
                            .padding(.vertical,16)
                        
                        HStack {
                            Text("트랙어스와 함께한 사람들")
                                .customFontStyle(.gray1_SB20)
                                .padding(.vertical, 8)
                            
                            Spacer()
                        }
                        
                        LazyVGrid(columns: gridItems, spacing: 10) {
                            ForEach(memberData.shuffled(), id: \.self) { data in
                                TeamIntroCell(TeamName: data.name, TeamImage: data.image, isDesigner: data.isDesigner)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    
                    Button {
                        router.present(sheet: .webView(url: Constants.WebViewUrl.Team_Trackus_GitHub_URL))
                    } label: {
                        Text("팀 트랙어스 GitHub")
                            .customFontStyle(.white_B16)
                            .frame(height: 56)
                            .frame(maxWidth: .infinity)
                            .background(.main)
                            .cornerRadius(50)
                    }
                }
                .padding(.horizontal, 16)
            }
            .customNavigation {
                NavigationText(title: "팀 트랙어스")
            } left: {
                NavigationBackButton()
            }
    }
}

struct TeamIntroCell: View {
    var TeamName: String
    var TeamImage: String
    var isDesigner: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(isDesigner ? "Designer" : "iOS Dev")
                    .customFontStyle(.main_B14)
                
                Spacer()
            }
            
            Image(TeamImage)
                .resizable()
                .frame(width: 100, height: 100)
            
            Text(TeamName)
                .customFontStyle(.gray1_SB15)
        }
        .padding(16)
        .modifier(BorderLineModifier())
    }
}

struct TrackUsMember: Hashable {
    var name: String
    var image: String
    var isDesigner: Bool
}

#Preview {
    TeamIntroView()
}
