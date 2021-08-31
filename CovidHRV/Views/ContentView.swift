//
//  ContentView.swift
//  CovidHRV
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications
import TabularData
struct ContentView: View {
    @StateObject var health = Health()
    @StateObject var ml = ML()
    @State var share = false
    @State var onboarding = UserDefaults.standard.bool(forKey: "onboarding")
    var body: some View {
        if !onboarding {
            OnboardingView(isOnboarding: $onboarding, isOnboarding2: $onboarding)
            
        } else {
        HomeView(health: health)//, ml: ml)
        
            .onAppear() {
                do {
//                let df = try DataFrame(contentsOfCSVFile: Bundle.main.url(forResource: "P355472-AppleWatch-hr", withExtension: "csv")!)
//                ml.importCSV(data: df) { data in
//                    health.healthData = data
//                    let risk = health.getRiskScore(bedTime: 0, wakeUpTime: 4, data: data)
//                    //print(risk.1)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                        let filtered = risk.1.filter {
//                        return $0.risk != 0 && $0.risk != 21
//                    }
//                    //print(health.codableRisk.count)
//                        print(filtered.count)
//                    }
//                }
                } catch {
                    
                }
                LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
                }
                let readData = Set([
                    HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!,
                    HKCategoryType(.sleepAnalysis),
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
//                for type in health.readData {
//                health.getHealthData(type: type, dateDistanceType: .Month, dateDistance: 24) { _ in
//
//                }
                //}
               
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
//                ml.exportDataToCSV(data: health.healthData) { _ in
//                    share = true
//                }
            }
            .sheet(isPresented: $share) {
                ShareSheet(activityItems: [ml.getDocumentsDirectory().appendingPathComponent("A.csv")])
                
            }
    }
           
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
