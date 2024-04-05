//
//  RunningStartView.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/19.
//

import SwiftUI

struct RunningStartView: View {
    @EnvironmentObject var router: Router
    @ObservedObject var runViewModel: RunActivityViewModel
    
    var body: some View {
        RunningActivityVCHosting(
            router: router,
            runViewModel: runViewModel
        )
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .preventGesture()
    }
}
