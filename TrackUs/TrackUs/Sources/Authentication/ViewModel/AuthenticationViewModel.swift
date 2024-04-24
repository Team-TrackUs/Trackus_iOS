//
//  AuthenticationViewModel.swift
//  TrackUs
//
//  Created by SeokKi Kwon on 2024/01/29.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit
import SwiftUI

enum AuthenticationState {
    case startapp
    case unauthenticated
    case authenticating
    case signUpcating
    case authenticated
}

enum AuthenticationError: Error {
    case tokenError(message: String)
}

class FirebaseManger: NSObject {
    static let shared = FirebaseManger()
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    //var flow: SignUpFlow = .nickname
    
    
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}

@MainActor
class AuthenticationViewModel: NSObject, ObservableObject {
    static let shared = AuthenticationViewModel()
    var chatListViewModel = ChatListViewModel.shared
    
    @Published var authenticationState: AuthenticationState = .startapp
    @Published var errorMessage: String = ""
    @Published var user: Firebase.User?
    @Published var userInfo: UserInfo = UserInfo()
    @Published var accessToken: String?
    
    // 외부 공유용 사용
    static var currentUid: String {
        shared.userInfo.uid
    }
    
    // apple login
    var window: UIWindow?
    fileprivate var currentNonce: String?

    
    private override init() {
        super.init()
        registerAuthStateHandler()
        //super.self.userInfo = UserInfo()
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                if user == nil {
                    self.authenticationState = .unauthenticated
                } else {
                    Task{
                        let check = try await Firestore.firestore().collection("users")
                            .whereField("uid", isEqualTo: user!.uid).getDocuments()
                        if check.isEmpty {
                            self.authenticationState = .signUpcating
                        }else {
                            self.getMyInformation()
                            self.chatListViewModel.subscribeToUpdates()
                            self.authenticationState = .authenticated
                            //self.accessToken = try await user?.getIDToken()
                        }
                    }
                }
            }
        }
    }
    
    // 닉네임 중복 체크
    func checkUser(username: String) async -> Bool {
        do {
            let querySnapshot = try await Firestore.firestore().collection("users")
                .whereField("username", isEqualTo: username).getDocuments()
            if querySnapshot.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            return true
        }
    }
    
    // MARK: - 로그아웃
    func logOut() {
        do {
            try Auth.auth().signOut()
            userInfo = UserInfo()
            
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 회원탈퇴
    func deleteAccount(withReason reason: String) async -> Bool {
        do {
            if let uid = Auth.auth().currentUser?.uid {
                // 사용자 프로필 이미지 삭제 (있을 경우)
                if let url = userInfo.profileImageUrl {
                    try await FirebaseManger.shared.storage.reference(forURL: url).delete()
                }
                try await user?.delete()
                try await Firestore.firestore().collection("users").document(uid).delete()
                print("Document successfully removed!")
                // 탈퇴 사유를 Firestore에 저장
                if !reason.isEmpty {
                    let withdrawalData = ["uid": uid,
                                          "reason": reason]
                    try await Firestore.firestore().collection("withdrawalReasons").addDocument(data: withdrawalData)
                }
            }
            self.authenticationState = .unauthenticated
            userInfo = UserInfo()
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            self.authenticationState = .unauthenticated
            print("ErrorMessage : ", errorMessage)
            print("deletAccount Error!!")
            return false
        }
    }
    
    // MARK: - Token값 등록
    func updateToken(_ token: String)  {
        guard let uid = FirebaseManger.shared.auth.currentUser?.uid else {
            return }
        
        let data = ["token": token]
        FirebaseManger.shared.firestore.collection("users").document(uid).updateData(data) { error in
            if let error = error {
                // 업데이트 중에 오류가 발생한 경우 처리
                print("Error updating token: \(error.localizedDescription)")
            } else {
                // 업데이트가 성공한 경우 처리
                print("Token updated successfully")
            }
        }
    }
}

// MARK: - SNS Login
extension AuthenticationViewModel {
    // MARK: - 구글 로그인
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("client ID 없음")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("root view controller 없음")
            return false
        }
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token 누락") }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            let auth = try await Auth.auth().signIn(with: credential)
            self.userInfo.uid = auth.user.uid
            self.accessToken = accessToken.tokenString
            return true
        }
        catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}


// MARK: - apple 로그인
extension AuthenticationViewModel{
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // Apple Login 필요 함수
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension AuthenticationViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            
            Task {
                do {
                    let auth = try await Auth.auth().signIn(with: credential)
                    self.userInfo.uid = auth.user.uid
                    if let accessToken = credential.accessToken {
                        self.accessToken = accessToken
                    }
                }
                catch {
                    print("Error authenticating: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}

extension AuthenticationViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return window ?? UIWindow()
    }
}

// MARK: - 사용자 정보 관련
extension AuthenticationViewModel {
    
    /// 이미지 저장 (이미지 저장 -> 사용자 저장 순)
    func storeUserInfoInFirebase() {
        // 이미지 유무 확인 후 저장
        guard let image = self.userInfo.image else {
            self.userInfo.profileImageUrl = nil
            self.storeUserInformation()
            return
        }
         
        guard let uid = FirebaseManger.shared.auth.currentUser?.uid else {
            return }
        //let ref = FirebaseManger.shared.storage.reference(withPath: uid)
        let ref = FirebaseManger.shared.storage.reference().child("usersImage/\(uid)")
        
        // 이미지 크기 줄이기 (용량 축소)
        guard let resizedImage = image.resizeWithWidth(width: 300) else {
            return }
        guard let  jpegData = resizedImage.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        // 이미지 포맷
        ref.putData(jpegData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Failed to push image to Storage: \(error)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error{
                    print("Failed to retrieve downloadURL: \(error)")
                    return
                }
                print("Successfully stored image with url: \(url?.absoluteString ?? "")")
                
                // 이미지 url 저장
                guard let url = url else {return}
                self.userInfo.profileImageUrl = url.absoluteString
                // firestore 저장
                self.storeUserInformation()
            }
        }
    }
    // MARK: - 사용자 정보 저장 - 위 이미지 저장함수와 순차적으로 사용
    private func storeUserInformation() {
        guard let uid = FirebaseManger.shared.auth.currentUser?.uid else {
            return }
        // 해당부분 자료형 지정 필요
        let userData = ["uid": uid,
                        "username": userInfo.username,
                        "weight": userInfo.weight as Any,
                        "height": userInfo.height as Any,
                        "age": userInfo.age as Any,
                        "gender": userInfo.gender as Any,
                        "isProfilePublic": userInfo.isProfilePublic,
                        "isProSubscriber": false,
                        "profileImageUrl": userInfo.profileImageUrl as Any,
                        "setDailyGoal": userInfo.setDailyGoal as Any,
                        "runningStyle": userInfo.runningStyle?.rawValue as Any,
                        "token": userInfo.token] as [String : Any]
        FirebaseManger.shared.firestore.collection("users").document(uid).setData(userData){ error in
            if error != nil {
                return
            }
            print("success")
        }
    }
    
    // MARK: - 사용자 본인 정보 불러오기
    func getMyInformation(){
        
        guard let user = FirebaseManger.shared.auth.currentUser else {
            print("error uid")
            return
        }
        FirebaseManger.shared.firestore.collection("users").document(user.uid).getDocument { snapshot, error in
            
            if let error = error {
                print("Error getting documents: \(error)")
            }else{
                do{
                    guard let firestoreUserInfo = try snapshot?.data(as: UserInfo.self) else { return }
                    self.userInfo = firestoreUserInfo
                    
                } catch {
                    print(error)
                }
            }
        }
        
        if let accessToken = user.refreshToken {
            self.accessToken = accessToken
        }
        getAccessToken { (token, error) in
            if let token = token {
                // AccessToken 사용
                self.accessToken = token
            } else if let error = error {
                // 오류 처리
                print("오류 발생: \(error.localizedDescription)")
            }
        }
        
    }
    
    // 사용자 accessToken 받아오기 -> Notification 관련 -> 이후 수정
    func getAccessToken(completion: @escaping (String?, Error?) -> Void) {
        // Firebase에 로그인하여 AccessToken을 가져오는 코드
        if let accessToken = Auth.auth().currentUser?.refreshToken {
            self.accessToken = accessToken
        }
        
    }

    
    func downloadImageFromStorage(uid: String) {
        guard let profileImageUrl = self.userInfo.profileImageUrl else {
            return
        }
        let ref = FirebaseManger.shared.storage.reference(forURL: profileImageUrl)
//
//        let storageRef = storage.reference(forURL: url.absoluteString)
        ref.getData(maxSize: 1 * 1024 * 1024)  { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else {
                // Data for "images/island.jpg" is returned
                self.userInfo.image = UIImage(data: data!)
            }
        }
    }
    

}

// MARK: - 이미지 수정 부분
// Image -> UIImage로 변환
extension Image {
    func asUIImage() -> UIImage {
        // Image를 UIImage로 변환하는 확장 메서드
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let size = controller.view.intrinsicContentSize
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}


// UIImage 사진 크기 축소
extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

// MARK: - 차단 사용자 관리
extension AuthenticationViewModel {
    
    
    /// 사용자 차단 - uid: 상대방 uid 지정
    func BlockingUser(uid: String) {
        // UserInfo 차단 리스트 추가
        self.userInfo.blockedUserList?.append(uid)
        // 본인 UserInfo에 차단 목록 추가
        FirebaseManger.shared.firestore.collection("users").document(userInfo.uid).updateData([
            "blockedUserList": FieldValue.arrayUnion([uid])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        
        // 상대방 UserInfo 추가
        FirebaseManger.shared.firestore.collection("users").document(uid).updateData([
            "blockingMeList": FieldValue.arrayUnion([userInfo.uid])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
    }
    
    /// 차단 해제  - uid: 상대방 uid 지정
    func UnblockingUser(uid: String) {
        // UserInfo 차단 리스트 제거
        self.userInfo.blockedUserList?.removeAll { $0 == uid }
        // 본인 UserInfo -> blockedUserList 차단 해제
        FirebaseManger.shared.firestore.collection("users").document(userInfo.uid).updateData([
            "blockedUserList": FieldValue.arrayRemove([uid])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
        
        // 상대방 UserInfo -> blockingMeList uid 지우기
        FirebaseManger.shared.firestore.collection("users").document(uid).updateData([
            "blockingMeList": FieldValue.arrayRemove([userInfo.uid])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            }
        }
    }
    
    // 차단 여부 확인 -> 상대방 uid 입력
    func checkBlocking(uid: String) -> Bool {
        guard let list = self.userInfo.blockedUserList else{ return false }
        return list.contains(uid)
    }
    
}
