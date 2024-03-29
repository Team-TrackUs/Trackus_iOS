//
//  ProfileEditView.swift
//  TrackUs
//
//  Created by 박소희 on 1/31/24.
//

import SwiftUI

struct ProfileEditView: View {
    //@Environment(\.dismiss) var dismiss
    
    @StateObject var authViewModel = AuthenticationViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: UIImage?
    @State private var nickname: String = ""
    @State private var height: Double?
    @State private var weight: Double?
    @State private var selectedRunningStyle: RunningStyle = .walking
    @State private var runningStyle: RunningStyle?
    @State private var setDailyGoal: Double?
    @State private var goalMinValue: Double?
    @State private var goalMaxValue: Double?
    @State private var isProfilePublic: Bool = false
    @State private var isProfileSaved: Bool = false
    
    
    @State private var heightPickerPresented: Bool = false
    @State private var weightPickerPresented: Bool = false
    @State private var runningStylePickerPresented: Bool = false
    @State private var setDailyGoalPickerPresented: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    // MARK: - 프로필 헤더
                    ProfilePicker(UIimage: $selectedImage, size: 116)
                    // MARK: - 프로필 정보
                    VStack(alignment: .leading, spacing: 32) {
                        // 닉네임
                        VStack(alignment: .leading, spacing: 20) {
                            Text("닉네임")
                                .customFontStyle(.gray1_B20)
                            TextField("닉네임을 입력해주세요", text: $nickname)
                                .padding(.leading, 16)
                                .foregroundColor(.gray1)
                                .frame(height: 47)
                                .textFieldStyle(PlainTextFieldStyle())
                                .cornerRadius(3)
                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.border))
                        }
                        
                        /**
                         신체정보 옵션
                         신장 120-250(단위 1)
                         체중 30-200(단위 1)
                         */
                        VStack(alignment: .leading, spacing: 20) {
                            Text("신체정보")
                                .customFontStyle(.gray1_B20)
                            
                            HStack {
                                Text("신장")
                                    .customFontStyle(.gray1_R16)
                                Spacer()
                                pickerButton(pickerPresented: $heightPickerPresented, value: height, unit: "cm")
                            }
                            
                            HStack {
                                Text("체중")
                                    .customFontStyle(.gray1_R16)
                                Spacer()
                                pickerButton(pickerPresented: $weightPickerPresented, value: weight, unit: "kg")
                            }
                        }
                        .padding(.vertical, 14)
                        
                        /**
                         운동정보 옵션
                         러닝스타일 - 기록갱신/다이어트
                         일일목표 - 0.0-40.0 (0.1 km)
                         */
                        VStack(alignment: .leading, spacing: 20) {
                            Text("운동정보")
                                .customFontStyle(.gray1_B20)
                            
                            HStack {
                                Text("러닝스타일")
                                    .customFontStyle(.gray1_R16)
                                Spacer()
                                Button(action: {
                                    selectedRunningStyle = runningStyle ?? .walking
                                    runningStylePickerPresented.toggle()
                                }, label: {
                                    HStack{
                                        if let value = runningStyle{
                                            Text(value.description)
                                                .customFontStyle(.gray1_R16)
                                        }else {
                                            Text("정보 없음")
                                                .customFontStyle(.gray2_L12)
                                        }
                                        Image(.pickerLogo)
                                            .resizable()
                                            .frame(width: 9,height: 18)
                                            .scaledToFit()
                                    }
                                })
                            }
                            
                            HStack {
                                Text("일일목표")
                                    .customFontStyle(.gray1_R16)
                                Spacer()
                                pickerButton(pickerPresented: $setDailyGoalPickerPresented, value: setDailyGoal, unit: "km", format: "%.1f")
                            }
                            
                        }
                        .padding(.vertical, 14)
                        
                        // 사용자 관련
                        VStack(alignment: .leading, spacing: 20) {
                            Text("사용자 관련")
                                .customFontStyle(.gray1_B20)
                            
                            HStack {
                                Text("프로필 공개 여부")
                                    .customFontStyle(.gray1_R16)
                                Spacer()
                                Toggle("프로필 공개 여부", isOn: $isProfilePublic)
                                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                                    .font(Font.system(size: 15, weight: .regular))
                                    .foregroundColor(Color.gray1)
                                    .labelsHidden()
                            }
                        }
                        .padding(.vertical, 14)
                    }
                }
                .padding(.horizontal, Constants.ViewLayout.VIEW_STANDARD_HORIZONTAL_SPACING)
            }
            .customNavigation {
                NavigationText(title: "프로필 변경")
            } left: {
                NavigationBackButton()
            }
            MainButton(active: true, buttonText: "수정완료", action: modifyButtonTapped)
                .padding(Constants.ViewLayout.VIEW_STANDARD_HORIZONTAL_SPACING)
                .simultaneousGesture(TapGesture().onEnded {
                })
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            //authViewModel.getMyInformation()
            selectedImage = authViewModel.userInfo.image
            nickname = authViewModel.userInfo.username
            height = authViewModel.userInfo.height.map { Double($0) }
            weight = authViewModel.userInfo.weight.map { Double($0) }
            runningStyle = authViewModel.userInfo.runningStyle
            setDailyGoal = authViewModel.userInfo.setDailyGoal
            isProfilePublic = authViewModel.userInfo.isProfilePublic
        }
        .sheet(isPresented: $heightPickerPresented) {
            PickerSheet(selectedValueBinding: $height, pickerType: .height, startingValue: height ?? 160)
        }
        .sheet(isPresented: $weightPickerPresented) {
            PickerSheet(selectedValueBinding: $weight, pickerType: .weight, startingValue: weight ?? 60)
        }
        .sheet(isPresented: $runningStylePickerPresented) {
            VStack{
                Text("러닝스타일 선택")
                    .customFontStyle(.gray1_B20)
                Picker("러닝스타일", selection: $selectedRunningStyle) {
                    ForEach(RunningStyle.allCases) { value in
                        Text(value.description).tag(value)
                    }
                }
                .customFontStyle(.gray1_M16)
                .pickerStyle(WheelPickerStyle())
                .presentationDetents([.height(300)])
                HStack(spacing: 8){
                    Button {
                        runningStylePickerPresented.toggle()
                    } label: {
                        Text("취소")
                            .customFontStyle(.main_R16)
                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 40)
                            .overlay(
                                Capsule()
                                    .stroke( .main, lineWidth: 1)
                            )
                    }
                    Button {
                        runningStyle = selectedRunningStyle
                        runningStylePickerPresented.toggle()
                    } label: {
                        Text("확인")
                            .customFontStyle(.white_B16)
                            .frame(width: 212, height: 40)
                            .background(.main)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(20)
            
        }
        .sheet(isPresented: $setDailyGoalPickerPresented) {
            PickerSheet(selectedValueBinding: $setDailyGoal, pickerType: .dailyGoal, startingValue: setDailyGoal ?? 1)
        }
        
    }
    
    
    func modifyButtonTapped() {
        authViewModel.userInfo.image = selectedImage
        authViewModel.userInfo.username = nickname
        authViewModel.userInfo.height = height.map { Int($0) }
        authViewModel.userInfo.weight = weight.map { Int($0) }
        authViewModel.userInfo.runningStyle = runningStyle
        authViewModel.userInfo.setDailyGoal = setDailyGoal
        authViewModel.userInfo.isProfilePublic = isProfilePublic
        authViewModel.storeUserInfoInFirebase()
        isProfileSaved = true
        presentationMode.wrappedValue.dismiss()
    }
}

struct pickerButton: View {
    @Binding private var pickerPresented: Bool
    private var value: Double?
    private var unit: String
    private var format: String
    
    init(pickerPresented: Binding<Bool>, value: Double? = nil, unit: String, format: String = "%.0f") {
        self._pickerPresented = pickerPresented
        self.value = value
        self.unit = unit
        self.format = format
    }
    
    var body: some View {
        Button(action: {
            pickerPresented.toggle()
        }, label: {
            HStack{
                if let value = value{
                    Text("\(String(format: format, value))\(unit)")
                        .customFontStyle(.gray1_R16)
                }else {
                    Text("정보 없음")
                        .customFontStyle(.gray2_L12)
                }
                Image(.pickerLogo)
                    .resizable()
                    .frame(width: 9,height: 18)
                    .scaledToFit()
            }
        })
    }
}
