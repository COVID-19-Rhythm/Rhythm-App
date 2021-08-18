//
//  CovidHRVApp.swift
//  CovidHRV
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
@main
struct CovidHRVApp: App {
    @State var isTrue = false
    var body: some Scene {
        WindowGroup {
            ContentView()
               
            //OnboardingView(isOnboarding: $isTrue, isOnboarding2: $isTrue)
        }
    }
}
