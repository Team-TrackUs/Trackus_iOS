//
//  CourseListViewModel.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/26.
//

import Foundation
import FirebaseFirestore

class CourseListViewModel: ObservableObject, HashableObject {
    private let authViewModel = AuthenticationViewModel.shared
    
    @Published var courseList = [Course]()
    
    var courseFromUnBlockList: [Course] {
        if let blockedCourseList = UserDefaults.standard.array(forKey: Constants.UserDefaultKeys.blockedCourse) as? [String] {
            return courseList.filter { !blockedCourseList.contains($0.uid) }
        } else {
            return courseList
        }
    }
    
    var courseFromBlockList: [Course] {
        if let blockedCourseList = UserDefaults.standard.array(forKey: Constants.UserDefaultKeys.blockedCourse) as? [String] {
            return courseList.filter { blockedCourseList.contains($0.uid) }
        } else {
            return []
        }
    }
    
    @MainActor
    var myCourseData: [Course] {
        let uid = authViewModel.userInfo.uid
        return courseList.filter { $0.members.contains(uid) }
    }
    
    init() {
        fetchCourseData()
    }
    
    /// 모집글 데이터 가져오기
    func fetchCourseData() {
        Firestore.firestore().collection("running")
            .whereField("isBlocked", isEqualTo: false)
            .limit(to: 10).getDocuments { snapShot, error in
            guard let documents = snapShot?.documents else { return }
            self.courseList = documents.compactMap  {(try? $0.data(as: Course.self))}.filter {$0.members.count > 0}
        }
    }
    
    
    /// 코스데이터 찾기
    func findCourseWithUID(_ uid: String) -> Course? {
        return courseList.filter { $0.uid == uid }.first
    }
    
    func deleteUserWithUID(_ uid: String) async {
        do {
          let snapShot = try await Firestore.firestore().collection("running").whereField("members", arrayContains: uid).getDocuments()
            let documents = snapShot.documents
           let data = documents.compactMap {(try? $0.data(as: Course.self))}
            try data.forEach {
                var newData = $0
                newData.members.remove(at: newData.members.firstIndex(of: uid)!)
                 try Firestore.firestore().collection("running").document($0.uid).setData(from: newData)
            }
                            
        } catch {
            
        }
    }
}
