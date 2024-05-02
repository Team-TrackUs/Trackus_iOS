//
//  CourseReportView.swift
//  TrackUs
//
//  Created by 석기권 on 4/29/24.
//

import SwiftUI
import Kingfisher

struct CourseReportView: View {
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @ObservedObject var courseVM: CourseViewModel
    @EnvironmentObject var router: Router
    
    @FocusState var isInputActive: Bool
    @State private var selectedReason : ReportReason? = nil // 신고메뉴
    @State private var reportText : String = "" // 신고내용
    @State private var showingAlert = false
    @State private var pickerPresented: Bool = false
    @State private var isReport: Bool = false
    @State private var successReport: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                VStack {
                    Text("신고 게시물")
                        .customFontStyle(.gray1_SB15)
                    
                    KFImage(URL(string: courseVM.course.routeImageUrl))
                        .placeholder({ProgressView()})
                        .onFailureImage(KFCrossPlatformImage(named: "profile_img"))
                        .resizable()
                        .frame(width: 140, height: 140)
                        .cornerRadius(12)
                    
                    Text(courseVM.course.title)
                        .customFontStyle(.gray1_R14)
                }
                .padding(.bottom, 20)
                
                HStack {
                    Text("신고 사유")
                        .customFontStyle(.gray1_SB15)
                    
                    Spacer()
                    
                    
                }
                // 커뮤니티 위반사례 피커
                Button {
                    pickerPresented.toggle()
                } label: {
                    HStack {
                        Text(selectedReason?.rawValue ?? "커뮤니티 위반사례")
                            .customFontStyle(selectedReason == nil ? .gray2_R16 : .gray1_R16)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .resizable()
                            .frame(width: 9, height: 15)
                            .foregroundColor(.gray1)
                    }
                    .padding()
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.gray1)
                }
            }
            .padding(.bottom, 20)
            
            VStack {
                HStack {
                    Text("신고 내용")
                        .customFontStyle(.gray1_SB15)
                    
                    Spacer()
                }
                // 텍스트 필드
                ZStack(alignment: .topLeading){
                    TextEditor(text: $reportText)
                        .customFontStyle(.gray1_R16)
                        .autocorrectionDisabled()
                        .focused($isInputActive)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button {
                                    isInputActive = false
                                } label: {
                                    Text("확인")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .frame(height: 100)
                        .padding(9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray1, lineWidth: 1)
                        )
                    if reportText.isEmpty{
                        Text("신고 사유에 대한 내용을 자세히 입력해주세요.")
                            .padding()
                            .customFontStyle(.gray2_R16)
                    }
                }
            }
            
            HStack {
                Text("허위 신고 적발시 허위 신고 유저에게 불이익이 발생할 수 있습니다.")
                    .customFontStyle(.gray2_R12)
                
                Spacer()
            }
            .padding(.top, 8)
            
            Spacer()
            
            Button {
                Task {
                    guard let selectedReason = selectedReason else { return }
                    let form = ReportForm(text: reportText, fromUser: authViewModel.userInfo.uid, toUser: courseVM.course.ownerUid, category: selectedReason.rawValue)
                    await courseVM.report(reason: form)
                    showingAlert = true
                }
            } label: {
                Text("신고하기")
                    .customFontStyle(.white_B16)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(reportText.isEmpty || selectedReason == nil ? .gray3 : .caution)
                    .cornerRadius(50)
            }
            .disabled(reportText.isEmpty || selectedReason == nil)
        }
        .sheet(isPresented: $pickerPresented, content: {
            reportPicker(selectedReason: $selectedReason, pickerPresented: $pickerPresented)
                .presentationDetents([.height(450)])
                .presentationDragIndicator(.visible)
        })
        .padding(.horizontal, 16)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("알림"), message: Text("신고가 성공적으로 접수되었습니다. 검토까지는 최대 24시간이 소요됩니다."), dismissButton: .default(Text("홈으로 이동"), action: {
                router.popToRoot()
            }))
            
        }
        .customNavigation {
            NavigationText(title: "게시물 신고")
        } left: {
            NavigationBackButton()
        }
        
    }
}

//#Preview {
//    ComplaintView()
//}
