//
//  OnboardingView.swift
//  OnboardingView
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import NiceNotifications
import HealthKit

struct OnboardingView: View {
    let healthStore = HKHealthStore()
    //@State var onboardingViews = [Onboarding(id: UUID(), image: "privacy", title: "Privacy First", description: "Zero data leaves your device unless you approve sharing your data to further research."), Onboarding(id: UUID(), image: "data", title: "Types of Data", description: "Tap below to learn how you can use your data."), Onboarding(id: UUID(), image: "ml", title: "On Device Machine Learning", description: "Fine-tune your machine learning model on device to learn when you could possibly be sick."), Onboarding(id: UUID(), image: "feel", title: "Simply Rate How You Feel", description: "Rating how your feeling further trains your model to understand how you feel and to possibly alert to potential signs of disease."), Onboarding(id: UUID(), image: "you", title: "You Know Yourself Best", description: "Even if you receive a notification that you are possibly catching an illness, it's always up to you whether you choose to self isolate or ignore the alert.")]
    
    @State var onboardingViews = [Onboarding(id: UUID(), image: "privacy", title: "Privacy First", description: "Zero data leaves your device unless you approve sharing your data to further research."), Onboarding(id: UUID(), image: "data", title: "Types of Data", description: "Learn how you can use your data."), Onboarding(id: UUID(), image: "ml", title: "On Device Machine Learning", description: "Fine-tune your machine learning model on device to learn when you could possibly be sick."), Onboarding(id: UUID(), image: "you", title: "You Know Yourself Best", description: "Even if you receive a notification that you are possibly catching an illness, it's always up to you whether you choose to self isolate or ignore the alert.")]
    @State var slideNum = 0
    @Binding var isOnboarding: Bool
    @Binding var isOnboarding2: Bool
    @State var time = 0
    //@Binding var setting: Setting
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            TabView(selection: $slideNum) {
                ForEach(onboardingViews.indices, id: \.self) { i in
                    OnboardingDetail(onboarding: onboardingViews[i])
                        .tag(i)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            if onboardingViews[slideNum].title.contains("Can") {
            Button(action: {
                if slideNum + 1 < onboardingViews.count  {
                    slideNum += 1
                } else {
                    // dismiss sheet
                    isOnboarding = true
                    UserDefaults.standard.set(true, forKey: "isOnboarding")
                }
                //setting.onOff = false
            }) {
                ZStack {
//                    RoundedRectangle(cornerRadius: 25.0)
//                        .foregroundColor(Color(.lightGray))
//                        .frame(height: 75)
//                        .padding()
                    Text("No")
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .foregroundColor(.white)
                }
            } .buttonStyle(CTAButtonStyle())
                    .frame(width: .infinity)
                    .padding()
            }
            Button(action: {
                if onboardingViews[slideNum].title.contains("Noti") {
                    LocalNotifications.requestPermission(strategy: .askSystemPermissionIfNeeded) { success in
                        if success {
//                            setting.onOff = true
                        }
                    }
                    
                } else if onboardingViews[slideNum].title.contains("Can we Access Your Health Data?") {
                    let readData = Set([
                        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                        HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                        HKObjectType.quantityType(forIdentifier: .heartRate)!,
                        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
                        HKObjectType.quantityType(forIdentifier: .stepCount)!
                    ])
                    
                    self.healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
                        
                    }
                }
                if slideNum + 1 < onboardingViews.count  {
                    slideNum += 1
                } else {
                    // dismiss sheet
                   isOnboarding = true
                   UserDefaults.standard.set(true, forKey: "isOnboarding")
                }
                
            }) {
                ZStack {
//                    RoundedRectangle(cornerRadius: 25.0)
//                        .foregroundColor(Color("teal"))
//                        .frame(height: 75)
//                        .padding()
                    Text(onboardingViews[slideNum].title.contains("Can") ? "Yes" : "Continue")
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                        .foregroundColor(.white)
                }
            } .buttonStyle(CTAButtonStyle())
                .frame(width: .infinity)
                .padding()
            
        }
    }
}

struct OnboardingDetail: View {
    @State var onboarding: Onboarding
    
    var body: some View {
        VStack {
            Text(onboarding.title)
                .font(.custom("Poppins-Bold", size: 24, relativeTo: .title))
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .fixedSize(horizontal: false, vertical: true)
            Text(onboarding.description)
                .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .fixedSize(horizontal: false, vertical: true)
            
            Image(onboarding.image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                .shadow(color: Color(.lightGray).opacity(0.4), radius: 40)
            
            if onboarding.image == "data" {
                DataTypesListView()
            }
        }
        .padding()
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

