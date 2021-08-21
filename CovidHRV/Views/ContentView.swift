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
    //@StateObject var ml = ML()
    @State var onboarding = UserDefaults.standard.bool(forKey: "onboarding")
    var body: some View {
        if !onboarding {
            OnboardingView(isOnboarding: $onboarding, isOnboarding2: $onboarding)
            
        } else {
        HomeView(health: health)//, ml: ml)
        
            .onAppear() {
                let readData = Set([
                    HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!,
                    HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                    HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                    HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                    HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
                    HKObjectType.quantityType(forIdentifier: .stepCount)!
                ])
                
                health.healthStore.requestAuthorization(toShare: [], read: readData) { (success, error) in
                    
                }
                let url3 = health.getDocumentsDirectory().appendingPathComponent("risk.txt")
                do {
                    
                    let input = try String(contentsOf: url3)
                    
                    
                    let jsonData = Data(input.utf8)
                    do {
                        let decoder = JSONDecoder()
                        
                        do {
                            let codableRisk = try decoder.decode([CodableRisk].self, from: jsonData)
                            
                            health.codableRisk = codableRisk
                            
                         
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } catch {
                    
                }
                for type in health.readData {
                health.getHealthData(type: type, dateDistanceType: .Month, dateDistance: 24) { _ in
                    
                }
                }
            }
            .onChange(of: health.risk) { value in
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(health.codableRisk) {
                    if let json = String(data: encoded, encoding: .utf8) {
                      
                        do {
                            let url = health.getDocumentsDirectory().appendingPathComponent("risk.txt")
                            try json.write(to: url, atomically: false, encoding: String.Encoding.utf8)
                            
                        } catch {
                            print("erorr")
                        }
                    }
                    
                    
                }
            }
    }
    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
