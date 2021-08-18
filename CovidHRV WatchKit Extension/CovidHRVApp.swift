//
//  CovidHRVApp.swift
//  CovidHRV WatchKit Extension
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI

@main
struct CovidHRVApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
