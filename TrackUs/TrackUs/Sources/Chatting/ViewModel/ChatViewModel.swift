//
//  ChatViewModel.swift
//  TrackUs
//
//  Created by 최주원 on 2/23/24.
//

import Foundation
import Firebase

class ChatViewModel: ObservableObject {
    
    @Published var currentChatID: String = ""
    @Published var members: [String : Member] = [:]
    @Published var messages: [Message] = []
    @Published var chatRoom: ChatRoom
    
    var newChat: Bool = false
    // 뭐지
    var lock = NSRecursiveLock()
    
    private let ref = FirebaseManger().firestore.collection("chatRoom")
    
    // navigaton 들어갈때 값 받기
    init(currentChatID: String, members: [String : Member], messages: [Message], chatRoom: ChatRoom) {
        self.currentChatID = currentChatID
        self.members = members
        self.messages = messages
        self.chatRoom = chatRoom
    }
    
    /// 기존 채팅방 생성자
    init(chatRoom: ChatRoom, users: [String: Member]){
        self.currentChatID = chatRoom.id
        self.chatRoom = chatRoom
        self.members = chatRoom.members.reduce(into: [String: Member]()) { result, uid in
            if let member = users[uid] {
                result[uid] = member
            }
        }
        subscribeToUpdates()
    }
    
    /// 1대1 채팅 생성자
    init(myInfo: UserInfo, opponentInfo: UserInfo){
        // 기존 채팅 있는지 확인
        self.chatRoom = ChatRoom(id: UUID().uuidString,
                                 title: "",
                                 members: [myInfo.uid, opponentInfo.uid],
                                 nonSelfMembers: [opponentInfo.uid],
                                 group: false)
        self.members = [myInfo.uid: Member(uid: myInfo.uid ,
                                          userName: myInfo.username,
                                          profileImageUrl: myInfo.profileImageUrl),
                        opponentInfo.uid: Member(uid: opponentInfo.uid,
                                               userName: opponentInfo.username,
                                               profileImageUrl: opponentInfo.profileImageUrl)]
        createChatRoom(myInfo: myInfo, opponentInfo: opponentInfo)
    }
    
    
    // 개인 채팅 신규
    func createChatRoom(myInfo: UserInfo, opponentInfo: UserInfo) {
        // 기존 채팅 있는지 확인
        ref.whereField("members", isEqualTo: [myInfo.uid, opponentInfo.uid])
            //.whereField("members", arrayContains: )
            .whereField("group", isEqualTo: false).getDocuments { snapshot, error in
                if let error = error {
                    print("@@@@@ error \(error)")
                    self.newChat = true
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let chatRoom = documents.compactMap{ document -> ChatRoom? in
                    do{
                        let firestoreChatRoom = try document.data(as: FirestoreChatRoom.self)
                        
                        var message: LatestMessageInChat? = nil
                        if let flm = firestoreChatRoom.latestMessage {
                            message = LatestMessageInChat(
                                //senderName: user.name,
                                timestamp: flm.timestamp,
                                text: flm.text.isEmpty ? "사진을 보냈습니다." : flm.text
                            )
                        }
                        return ChatRoom(id: document.documentID,
                                                        title: firestoreChatRoom.title,
                                                        members: firestoreChatRoom.members,
                                                        nonSelfMembers: firestoreChatRoom.members.filter { $0 != myInfo.uid },
                                                        usersUnreadCountInfo: firestoreChatRoom.usersUnreadCountInfo,
                                                        group: false,
                                                        latestMessage: message)
                    }catch {
                        print(error)
                    }
                    return nil
                }
                // 비어있음 - 신규
                if chatRoom.isEmpty {
                    self.newChat = true
                    return
                }
                self.chatRoom = chatRoom.first!
                self.currentChatID = chatRoom.first!.id
                self.subscribeToUpdates()
            }
    }
    
    
    // 채팅방 리스너
    func subscribeToUpdates() {
        ref.document(chatRoom.id)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener() { [weak self] (snapshot, _) in
                guard let self = self else { return }
                
                let messages = snapshot?.documents
                    .compactMap { try? $0.data(as: FirestoreMessage.self) }
                    .compactMap { firestoreMessage -> Message? in
                        guard
                            let id = firestoreMessage.id,
                            let timestamp = firestoreMessage.timestamp,
                            let sendMember = self.members[firestoreMessage.userId]
                        else{ return nil }
                        
                        let text = firestoreMessage.text
                        let imageUrl = firestoreMessage.imageUrl
                        
                        return Message(
                            id: id,
                            timestamp: timestamp,
                            imageUrl: imageUrl,
                            text: text,
                            sendMember: sendMember
                        )
                    } ?? []
                self.lock.withLock {
                    self.messages = messages
                        .sorted { $0.timestamp < $1.timestamp }
                }
                
            }
    }
    // 신규 메세지 갯수 리스너
//    func subscribeToUnreadCount() {
//        
//    }
    
    // 채팅방 리스너 종료 -> 이전 페이지
    
    // 채팅방 나가기
    func leaveChatRoom(chatRoomID: String, userUID: String) {
        ref.document(chatRoomID).updateData([
            "members": FieldValue.arrayRemove([userUID])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
    }
    
    // 채팅 메시지 전송
    func sendChatMessage(chatText: String, image: UIImage? = nil, uid: String) {
        if chatText.isEmpty { return }
        // 이미지 있을 경우
        if self.newChat {
            let newChatRoom: [String: Any] = [
                "title": "",
                "group": false,
                "members": chatRoom.members,
                "usersUnreadCountInfo": chatRoom.usersUnreadCountInfo
                //"latestMessage": nil
            ]  as [String : Any]
            ref.document(chatRoom.id).setData(newChatRoom)
            self.newChat = false
            subscribeToUpdates()
        }
        
        let messageData: [String: Any] = [
            "userId": uid,
            "text": chatText,
            // 이미지 작업 추가하면 해당 수정
            "imageUrl": image as Any,
            "timestamp": Date() // 현재 시간을 타임스탬프로 변환
        ]
        
        let latestMessageData: [String: Any] = [
            "text": chatText,
            // 이미지 작업 추가하면 해당 수정
            "timestamp": Date() // 현재 시간을 타임스탬프로 변환
        ]

        
        let id = UUID().uuidString
        ref.document(chatRoom.id).collection("messages").document(id).setData(messageData) {  error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        bumpUnre3adCounters(myuid: uid)
        // 마지막 메세지 수정
        ref.document(chatRoom.id)
            .updateData(["latestMessage" : latestMessageData])
    }
    
    // 사용자 메세지 확인 후 초기화 - 채팅방 들어올때
    func resetUnreadCounter(myuid: String) {
        var usersUnreadCountInfo = chatRoom.usersUnreadCountInfo
        usersUnreadCountInfo[myuid] = 0
        ref.document(chatRoom.id).updateData(["usersUnreadCountInfo" : usersUnreadCountInfo])
    }
    
    // 본인 제외 안읽은 메세지 1개씩 추가 - 메세지 전송때
    func bumpUnre3adCounters(myuid: String) {
        var usersUnreadCountInfo = chatRoom.usersUnreadCountInfo
        usersUnreadCountInfo = usersUnreadCountInfo.mapValues { $0 + 1 }
        usersUnreadCountInfo[myuid] = 0
        ref.document(chatRoom.id).updateData(["usersUnreadCountInfo" : usersUnreadCountInfo])
    }
    
    // 마지막 메세지 변경
    
}
