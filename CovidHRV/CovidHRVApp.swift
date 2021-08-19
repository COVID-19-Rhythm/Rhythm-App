//
//  CovidHRVApp.swift
//  CovidHRV
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications
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
    var healthData = [HealthData]()
    var healthStore = HKHealthStore()
  
    private var useCount = UserDefaults.standard.integer(forKey: "useCount")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        backgroundDelivery()
        return true
    }
func getHealthData(type: HKQuantityTypeIdentifier, dateDistanceType: DateDistanceType, dateDistance: Int, completionHandler: @escaping ([HealthData]) -> Void) {
    DispatchQueue.main.async {
    let data = [HealthData]()
    let calendar = NSCalendar.current
    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: NSDate() as Date)
    
    let offset = (7 + anchorComponents.weekday! - 2) % 7
    
    anchorComponents.day! -= offset
    anchorComponents.hour = 2
    
    guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
        fatalError("*** unable to create a valid date from the given components ***")
    }
    
    let interval = NSDateComponents()
    interval.minute = 30
    
    let endDate = Date()
    
    guard let startDate = calendar.date(byAdding: (dateDistanceType == .Week ? .day : .month), value: -dateDistance, to: endDate) else {
        fatalError("*** Unable to calculate the start date ***")
    }
    guard let quantityType3 = HKObjectType.quantityType(forIdentifier: type) else {
        fatalError("*** Unable to create a step count type ***")
    }
    
    let query3 = HKStatisticsCollectionQuery(quantityType: quantityType3,
                                             quantitySamplePredicate: nil,
                                             options: [.discreteAverage],
                                             anchorDate: anchorDate,
                                             intervalComponents: interval as DateComponents)
    
    query3.initialResultsHandler = {
        query, results, error in
        
        if let statsCollection = results {
            
            
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                //print(statsCollection.sources().first?.name)
                
                //if statsCollection.sources().last?.name == UIDevice.current.name {
                //print(UIDevice.current.name)
                if let quantity = statistics.averageQuantity() {
                    
                    let date = statistics.startDate
                    //for: E.g. for steps it's HKUnit.count()
                    let value = quantity.is(compatibleWith: .percent()) ? quantity.doubleValue(for: .percent()) : quantity.is(compatibleWith: .count()) ? quantity.doubleValue(for: .count()) : quantity.is(compatibleWith: .inch()) ? quantity.doubleValue(for: .inch()) : quantity.is(compatibleWith: HKUnit.count().unitDivided(by: HKUnit.minute())) ? quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) : quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour()))
                    //data.append(UserData(id: UUID().uuidString, type: .Balance, title: type.rawValue, text: "", date: date, data: value))
                    
                    self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: type.rawValue, text: "", date: date, data: value))
                    print(type.rawValue)
                    
                    
                }
                //  }
            }
            
        }
        
        completionHandler(data)
    }
        //self.convertHealthDataToChart(healthData: self.healthData) { _ in
        
    
        self.healthStore.execute(query3)
    
    }
}
    
func backgroundDelivery() {
    let readType2 = HKObjectType.quantityType(forIdentifier: .heartRate)
    #warning("switch to daily")
    healthStore.enableBackgroundDelivery(for: readType2!, frequency: .immediate) { success, error in
        if !success {
            print("Error enabling background delivery for type \(readType2!.identifier): \(error.debugDescription)")
        } else {
            print("Success enabling background delivery for type \(readType2!.identifier)")
            self.getHealthData(type: HKQuantityTypeIdentifier.heartRate, dateDistanceType: .Week, dateDistance: 1) { _ in
                print("YAH!")
            
            }
        }
       
        
       
}
}
func getRiskScore(bedTime: Int, wakeUpTime: Int) {
    var medianHeartrate = 0.0
    let url3 = getDocumentsDirectory().appendingPathComponent("risk.txt")
    do {
        
        let input = try String(contentsOf: url3)
        
        
        let jsonData = Data(input.utf8)
        do {
            let decoder = JSONDecoder()
            
            do {
                let codableRisk = try decoder.decode([CodableRisk].self, from: jsonData)
                
                medianHeartrate = codableRisk.map{Int($0.risk)}.median()
                
             
            } catch {
                print(error.localizedDescription)
            }
        }
    } catch {
        
    }
    let filteredToNight = healthData.filter {
        return $0.date.get(.hour) > bedTime && $0.date.get(.hour) < wakeUpTime
    }
    let filteredToHeartRate = filteredToNight.filter {
        return $0.title == HKQuantityTypeIdentifier.heartRate.rawValue
    }
    var heartRates = [Double]()
    var dates = [Date]()
    for hour in bedTime...wakeUpTime {
       
        let filteredToHour = filteredToHeartRate.filter { data in
            return data.date.get(.hour) == hour
        }
        heartRates.append(average(numbers: filteredToHour.map{$0.data}))
        dates.append(filteredToHour.last?.date ?? Date())
    }
    let riskScore = average(numbers: heartRates) > medianHeartrate + 4 ? 1 : 0
    let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: [Explanation]())
    if risk.risk > 0 {
        LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
            Today()
                .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
                .schedule(title: "First Friday", body: "Oakland let's go!")
        }
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
//    self.risk = risk
//    codableRisk.append(CodableRisk(id: risk.id, date: dates.last ?? Date(), risk: risk.risk, explanation: [String]()))

    //return (self.risk, codableRisk)
}
func average(numbers: [Double]) -> Double {
   // print(numbers)
   return Double(numbers.reduce(0,+))/Double(numbers.count)
}
}
