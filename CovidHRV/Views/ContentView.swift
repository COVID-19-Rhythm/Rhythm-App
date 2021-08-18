//
//  ContentView.swift
//  CovidHRV
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
struct ContentView: View {
    @StateObject var health = Health()
    @StateObject var ml = ML()
    var body: some View {
        HomeView(health: health, ml: ml)
            .onAppear() {
                let readData = Set([
                    HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                    HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                    HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                    HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
                ])
                
                health.healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
                    
                }
            }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
