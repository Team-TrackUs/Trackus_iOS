//
//  BlockedPost.swift
//  TrackUs
//
//  Created by 석기권 on 4/29/24.
//

import SwiftUI
import Kingfisher

struct BlockedPost: View {
    let courseVM: CourseViewModel
    let completion: () -> Void
    
    
    
    var body: some View {
        HStack {
            KFImage(URL(string: courseVM.course.routeImageUrl))
                .placeholder({ProgressView()})
                .onFailureImage(KFCrossPlatformImage(named: "profile_img"))
                .resizable()
                .frame(width: 70, height: 70)
                .cornerRadius(12)
            Spacer()
            VStack {
                HStack {
                    Text(courseVM.course.title)
                        .customFontStyle(.gray1_M16)
                    Spacer()
                }
            }
            Spacer()
            Button(action: {
                courseVM.unblockCourse(uid: courseVM.course.uid)
                completion()
            }) {
                Text("차단해제")
            }
//            MainButton(buttonText: "차단해제") {
//                courseVM.unblockCourse(uid: courseVM.course.uid)
//                completion()
//            }
        }
    }
}

//#Preview {
//    BlockedPost()
//}
