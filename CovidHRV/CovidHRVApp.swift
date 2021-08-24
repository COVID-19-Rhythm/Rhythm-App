//
//  CovidHRVApp.swift
//  CovidHRV
//
//  Created by Andreas on 8/17/21.
//


import SwiftUI

@main
struct CovidHRVApp: App {
    @State var isTrue = false
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                
}
    }
}
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  
    private var useCount = UserDefaults.standard.integer(forKey: "useCount")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  backgroundDelivery()
        return true
    }

}
