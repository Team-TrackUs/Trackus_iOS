//
//  RunningResultView.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/05.
//

import SwiftUI

struct RunningResultView: View {
    @EnvironmentObject var router: Router
    @ObservedObject var runViewModel: RunActivityViewModel
    @State private var showingModal = false
    @State private var showingAlert = false
    private let workoutService: WorkoutService!
    
    init(runViewModel: RunActivityViewModel) {
        self.runViewModel = runViewModel
        self.workoutService = WorkoutService(
            distance: runViewModel.distance,
            target: runViewModel.target,
            seconds: runViewModel.seconds,
            calorie: runViewModel.calorie
        )
    }
}

extension RunningResultView {
    var body: some View {
        VStack {
            MainMapVCHosting()
            
            VStack {
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 27)
                        .fill(.indicator)
                        .frame(
                            width: 32,
                            height: 4
                        )
                    
                    Text("러닝 결과")
                        .customFontStyle(.gray1_SB20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("운동량")
                            .customFontStyle(.gray1_R16)
                        
                        HStack {
                            Image(.distanceIcon)
                            VStack(alignment: .leading) {
                                Text("킬로미터")
                                Text(workoutService.compKilometerLabel)
                                    .customFontStyle(.gray1_R14)
                            }
                            Spacer()
                            Text(workoutService.compKilometerLabel)
                                .customFontStyle(.gray1_R12)
                        }
                        
                        HStack {
                            Image(.fireIcon)
                            VStack(alignment: .leading) {
                                Text("소모 칼로리")
                                Text(workoutService.compCaloriesLabel)
                                    .customFontStyle(.gray1_R14)
                            }
                            Spacer()
                            Text(workoutService.compCaloriesLabel)
                                .customFontStyle(.gray1_R12)
                        }
                        
                        HStack {
                            Image(.timeImg)
                            VStack(alignment: .leading) {
                                Text("러닝 타임")
                                Text(workoutService.compElapsedTimeLabel)
                                    .customFontStyle(.gray1_R14)
                            }
                            Spacer()
                            Text(workoutService.compElapsedTimeLabel)
                                .customFontStyle(.gray1_R12)
                        }
                        
                        HStack {
                            Image(.paceIcon)
                            VStack(alignment: .leading) {
                                Text("페이스")
                                Text(runViewModel.pace.asString(unit: .pace))
                                    .customFontStyle(.gray1_R14)
                            }
                            Spacer()
                            Text("-")
                                .customFontStyle(.gray1_R12)
                        }
                    }
                    
                    HStack {
                        Text(workoutService.feedbackMessageLabel)
                            .customFontStyle(.gray1_R14)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    
                    HStack(spacing: 28) {
                        MainButton(active: true, buttonText: "홈으로 가기", buttonColor: .gray1, minHeight: 45) {
                            showingAlert = true
                        }
                        
                        MainButton(active: true, buttonText: "러닝 기록 저장", buttonColor: .main, minHeight: 45) {
                            showingModal = true
                        }
                        
                    }
                }
                .padding(20)
            }
            .zIndex(2)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(
                .rect (
                    topLeadingRadius: 12,
                    topTrailingRadius: 12
                )
            )
            .offset(y: -10)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("홈으로 이동"),
                message: Text("홈으로 이동 하시겠습니까? 홈으로 이동하면 러닝 데이터가 리포트에 반영되지 않습니다."),
                primaryButton: .default (
                    Text("취소"),
                    action: { }
                ),
                secondaryButton: .destructive (
                    Text("이동"),
                    action: {
                        router.popToRoot()
                    }
                )
            )
        }
        .popup(isPresented: $showingModal) {
            SaveDataModal {
                showingModal = false
                
                Task {
                    do {
                        try await runViewModel.saveRunDataToFirestore()
                    } catch {
                        
                    }
                }
            } cancle: {
                self.showingModal = false
            }
            
            
        } customize: {
            $0
                .backgroundColor(.black.opacity(0.3))
                .isOpaque(false)
                .dragToDismiss(false)
                .closeOnTap(false)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea(.keyboard)
        .preventGesture()
    }
}


struct SaveDataModal: View {
    @FocusState private var titleTextFieldFocused: Bool
    
    let action: () -> ()
    let cancle: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("러닝 기록 저장")
                    .customFontStyle(.gray1_B16)
                
                Text("러닝기록 저장을 위해\n러닝의 이름을 설정해주세요.")
                    .customFontStyle(.gray1_R14)
                    .padding(.top, 8)
                
                VStack {
                    TextField("저장할 러닝 이름을 입력해주세요.", text: .constant("테스트"))
                        .customFontStyle(.gray1_R12)
                        .padding(8)
                        .frame(height: 32)
                        .textFieldStyle(PlainTextFieldStyle())
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(titleTextFieldFocused ? .main : .gray2))
                        .focused($titleTextFieldFocused)
                }
                .padding(.top, 16)
                
                HStack {
                    Spacer()
                    Button(action: cancle, label: {
                        Text("취소")
                            .customFontStyle(.main_R16)
                            .frame(minHeight: 40)
                            .padding(.horizontal, 20)
                            .overlay(Capsule().stroke(.main))
                    })
                    
                    Spacer()
                    
                    Button(action: action, label: {
                        Text("확인")
                            .customFontStyle(.white_B16)
                            .frame(minHeight: 40)
                            .padding(.horizontal, 20)
                            .background(.main)
                            .clipShape(Capsule())
                    })
                    Spacer()
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        
        .frame(width: 290, alignment: .leading)
        .background(.white)
        .cornerRadius(12)
    }
}



