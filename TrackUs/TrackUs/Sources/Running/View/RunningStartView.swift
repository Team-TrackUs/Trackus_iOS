//
//  RunningStartView.swift
//  TrackUs
//
//  Created by 석기권 on 2024/02/19.
//

import SwiftUI

struct RunningStartView: View {
    @EnvironmentObject var router: Router
    @StateObject var healthKitViewModel = HealthKitViewModel()
    
    var body: some View {
        TrackingModeMapView(
            router: router,
            healthKitViewModel: healthKitViewModel
        )
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .preventGesture()
    }
}
