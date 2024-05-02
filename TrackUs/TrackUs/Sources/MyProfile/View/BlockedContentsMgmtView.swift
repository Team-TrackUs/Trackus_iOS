//
//  BlockedContentsMgmtView.swift
//  TrackUs
//
//  Created by 석기권 on 4/29/24.
//

import SwiftUI
import Kingfisher

struct BlockedContentsMgmtView: View {
    @EnvironmentObject var courseListViewModel: CourseListViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                if !courseListViewModel.courseFromBlockList.isEmpty {
                    LazyVStack {
                        ForEach(courseListViewModel.courseFromBlockList, id: \.self) { course in
                            BlockedPost(courseVM: CourseViewModel(course: course)) {
                                courseListViewModel.fetchCourseData()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                  Text("차단된 게시물이 존재하지 않습니다.")
                        .font(.headline)
                        .foregroundStyle(.gray4)
                }
            }
        }
        .customNavigation {
            NavigationText(title: "차단 게시물")
        } left: {
            NavigationBackButton()
        }

    }
}

//#Preview {
//    BlockedContentsMgmtView()
//}
