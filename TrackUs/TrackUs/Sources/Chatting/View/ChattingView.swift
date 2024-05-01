//
//  UserExample.swift
//  TrackUs
//
//  Created by 윤준성 on 2/19/24.
//

import SwiftUI


struct ChattingView: View {
    @EnvironmentObject var router: Router
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @StateObject var chatViewModel: ChatViewModel
    
    @State private var sideMenuPresented: Bool = false
    @State private var sendMessage: String = ""
    
    @State private var sideMenuTranslation: CGFloat = 0
    
    // 높이 확인 용
    @State private var contentHeight: CGFloat = .zero
    
    @State var previousUser: String?
    
    @State private var title: String = ""
    @State private var scrollToBottom = false // State 변수 추가
    
    @State private var reportAlert = false
    
    private func updatePreviousSender(_ sender: String) -> Bool{
        if previousUser != sender {
            self.previousUser = sender
            return true
        }else{
            previousUser = nil
            return false
        }
    }
    
    var body: some View {
        ZStack(alignment: .trailing){
            VStack(alignment: .leading){
                // 채팅 내용 표기
                ScrollViewReader{ proxy in
                    ScrollView{
                        VStack(spacing: 2 ) {
                            ForEach(chatViewModel.messageMap, id: \.message) { messageMap in
                                ChatMessageView(messageMap: messageMap,
                                                myUid: authViewModel.userInfo.uid)
                                .padding(.horizontal, 16)
                                .id(messageMap)
                            }
                        }
                        
                    }
                    .onChange(of: chatViewModel.messageMap.count) { _ in // 새 메시지가 추가될 때마다 호출
//                        if let lastIndex = chatViewModel.messageMap.indices.last {
//                            withAnimation {
//                                proxy.scrollTo(chatViewModel.messageMap[lastIndex], anchor: .bottom)
//                            }
//                            // Check if the proxy is at the bottom
//                            let offset = proxy.frame(for: chatViewModel.messageMap[lastIndex]).maxY
//                            let scrollViewHeight = proxy.frame(in: .global).height
//                            let bottomOffset = scrollViewHeight - offset
//                            scrollToBottom = bottomOffset < 100 // You can adjust the threshold
//                        }
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(chatViewModel.messageMap.last!.message, anchor: .top)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(chatViewModel.messageMap.last?.message, anchor: .top)
                    }
                    // 아래 내리기
//                    .overlay(
//                        VStack {
//                            if !scrollToBottom {
//                                Button("신규 메세지") {
//                                    scrollToBottom(proxy)
//                                    scrollToBottom = true
//                                }
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                                .padding()
//                                .onTapGesture {
//                                    scrollToBottom = true
//                                }
//                            }
//                        }
//                        , alignment: .bottom
//                    )
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                        scrollToBottom = false
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                        scrollToBottom = false
                    }
                }
                Spacer()
                messageBar
                    .padding(.horizontal, 16)
            }
            .customNavigation {
                Text(title)
            } left: {
                NavigationBackButton()
            } right: {
                Button(
                    action: {
                        sideMenuPresented.toggle()
                        sideMenuTranslation = 0
                    }, label: {
                        // 이미지 추후 수정
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.gray1)
                    })
            }
            //.padding(.horizontal, 16)
            if sideMenuPresented{
                Color.gray.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        sideMenuPresented.toggle()
                    }
            }
            SideMenuView
                .frame(width: 300)
                .offset(x: sideMenuPresented ? sideMenuTranslation : 300, y: 0)
                .animation(.easeInOut, value: sideMenuPresented)
                .gesture(
                    DragGesture()
                        .onChanged{ value in
                            if value.translation.width > 0 {
                                sideMenuTranslation = value.translation.width
                            }
                        }.onEnded{ value in
                            let dragOffset = value.translation.width
                            
                            if dragOffset < 30 {
                                sideMenuTranslation = -0
                            }else {
                                sideMenuTranslation = .zero
                                sideMenuPresented.toggle()
                            }
                        }
                    )
            
            
        }
        .onAppear {
            title = chatViewModel.chatRoom.group ? chatViewModel.chatRoom.title : chatViewModel.members[chatViewModel.chatRoom.nonSelfMembers.first!]?.userName ?? "러너"
            chatViewModel.resetUnreadCounter(myuid: authViewModel.userInfo.uid)
            
        }
        .animation(.easeInOut, value: sideMenuPresented)
        .onDisappear {
            // 메세지 읽음 확인
            chatViewModel.resetUnreadCounter(myuid: authViewModel.userInfo.uid)
        }

        

    }
    // MARK: - 메세지 전송 바
    var messageBar: some View {
        // 하단 메세지 보내기
        HStack(alignment: .bottom, spacing: 12){
            ZStack{
                TextField("대화를 입력해주세요.", text: $sendMessage, axis: .vertical)
                    .customFontStyle(.gray1_R14)
                    .lineLimit(1...5)
                    .padding(10)
            }
            
            // 사진 촬영 업로드 버튼
//            Button(
//                action: {
//
//                }, label: {
//                    Image(systemName: "camera")
//                        .resizable()
//                        .foregroundStyle(.gray1)
//                        .frame(width: 20, height: 18)
//                        .padding(.vertical, 9)
//                })
//
//            // 사진 업로드 버튼
//            Button(
//                action: {
//
//                }, label: {
//                    Image(systemName: "photo")
//                        .resizable()
//                        .foregroundStyle(.gray1)
//                        .frame(width: 18, height: 18)
//                        .padding(.vertical, 9)
//                })
            // 메세지 전송 버튼
            Button(
                action: {
                    if authViewModel.userInfo.reportIDList?.count ?? 0 >= 3{
                        // 신고 횟수 누적 3회 이상의 경우
                        print("채팅 불가")
                        reportAlert.toggle()
                    }else {
                        // 메세지 전송 함수
                        chatViewModel.sendChatMessage(chatText: sendMessage, uid: authViewModel.userInfo.uid)
                        sendMessage = ""
                    }
                }, label: {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .foregroundStyle(.main)
                        .frame(width: 36, height: 36)
                })
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray3, lineWidth: 1)
        )
        .alert("채팅 제한",
               isPresented: $reportAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("신고로 인해 채팅이 일시 제한되었습니다.\n\n자세한 내용은 아래 메일을 통해\n문의해주시기 바랍니다.\nteam.trackus@gmail.com")
        }
    }
    // MARK: - 사이드 메뉴 View
    var SideMenuView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 제목부분
            VStack(alignment: .leading, spacing: 6){
                Text(title)
                    .customFontStyle(.gray1_B16)
                HStack{
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundStyle(.gray1)
                        .frame(width: 12, height: 12)
                    // 인원수
                    Text("\(chatViewModel.members.count)")
                        .customFontStyle(.gray1_R12)
                }
            }
            .padding(16)
            
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundStyle(.gray3)
            VStack(alignment: .leading, spacing: 6){
                Text("채팅방 맴버")
                    .customFontStyle(.gray1_R12)
                // 참여 중인 사용자 프로필 정보
                ForEach(chatViewModel.chatRoom.members, id: \.self) { uid in
                    if let member = chatViewModel.members[uid]{
                        Button {
                            router.push(.userProfile(uid))
                        } label: {
                            HStack{
                                ProfileImage(ImageUrl: member.profileImageUrl, size: 40)
                                Text(member.userName)
                                    .customFontStyle(.gray1_R14)
                            }
                        }
                    }

                    
                }
            }
            .padding(16)
            Spacer()
            
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundStyle(.gray3)
            Button(action: {
                // 나가기 기능
                if chatViewModel.chatRoom.group {
                    chatViewModel.leaveChatRoom(chatRoomID: chatViewModel.chatRoom.id, userUID: authViewModel.userInfo.uid)
                }else {
                    chatViewModel.deleteChatRoom(chatRoomID: chatViewModel.chatRoom.id)
                }
                router.pop()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .foregroundStyle(.gray1)
            }
            .padding(16)
        }
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.white)
        .transition(.move(edge: .trailing)) // 오른쪽에서 나오도록 애니메이션 적용
    }
}
// MARK: - 채팅 메세지
struct ChatMessageView: View {
    @EnvironmentObject var router: Router
    //@Binding var previousUser: String
    
    private let messageMap: MessageMap
    private let mymessge: Bool
    
    //@State private var previousUser: Bool = false
    @State private var previousdate: Bool = false
    
    init(messageMap: MessageMap, myUid: String) {
        self.messageMap = messageMap
        self.mymessge = messageMap.message.sendMember.uid == myUid
    }
    
    var body: some View {
        HStack{
            if !messageMap.sameDate{
                Text(messageMap.message.date)
                    .customFontStyle(.gray2_R12)
                    .padding(8)
            }
        }
        
        HStack(alignment: .top) {
            if !mymessge && (!messageMap.sameUser || !messageMap.sameDate) {
                Button {
                    router.push(.userProfile(messageMap.message.sendMember.uid))
                } label: {
                    HStack{
                        ProfileImage(ImageUrl: messageMap.message.sendMember.profileImageUrl, size: 40)
                            .padding(.top, 8)
                    }
                }
            }else{
                Spacer(minLength: 47)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if !mymessge && (!messageMap.sameUser || !messageMap.sameDate) {
                    let userName = messageMap.message.sendMember.userName
                    Text(userName.isEmpty ? "탈퇴 회원" : userName) // 상대방 이름
                        .customFontStyle(.gray1_R12)
                        .padding(.top, 8)
                }
                HStack(alignment: .bottom){
                    if mymessge && messageMap.sameTime {
                        Spacer()
                        Text(messageMap.message.time) // 메시지 작성 시간
                            .customFontStyle(.gray1_R12)
                    }
                    Text(messageMap.message.text!) // 메시지 내용
                        .customFontStyle(mymessge ? .white_M14 : .gray1_R14)
                        .padding(8)
                        .background(mymessge ? .main : .gray3)
                        .cornerRadius(10)
                    if !mymessge && messageMap.sameTime {
                        Text(messageMap.message.time) // 메시지 작성 시간
                            .customFontStyle(.gray1_R12)
                    }
                    if !mymessge {
                        Spacer()
                    }
                }
                
            }
            
            
        }
//        .onAppear {
//            previousUser = previoosUser1 == message.sendMember.uid ? false : true
//            previousdate = previousdate1 == message.date ? false : true
//            previoosUser1 = message.sendMember.uid
//            previousdate1 = message.date
//        }
    }
}

extension ChattingView {
    func scrollToBottom(_ proxy: ScrollViewProxy?) {
        // 스크롤 뷰를 제일 하단으로 스크롤합니다.
        if let proxy = proxy {
            withAnimation {
                proxy.scrollTo(chatViewModel.messageMap.last!.message, anchor: .top)
            }
        }
        // 스크롤 뷰의 제일 하단이 아님을 표시합니다.
        scrollToBottom = false
    }
}
