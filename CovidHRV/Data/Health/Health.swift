//
//  Health.swift
//  Health
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
class Health: ObservableObject {
    
    @Published var healthStore = HKHealthStore()
    @Published var risk = Risk(id: "demo", risk: 1.0, explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Explain it here!!"), Explanation(image: .questionmarkCircle, explanation: "Explain it here?"), Explanation(image: .circle, explanation: "Explain it here.")])
    @Published var readData: [HKQuantityTypeIdentifier] =  [.heartRateVariabilitySDNN,
                                .restingHeartRate,
                                .walkingHeartRateAverage,
                                .heartRate,
                                .walkingSpeed,
                                .respiratoryRate]
    @Published var healthData = [HealthData]()
    @Published var tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: "", text: "", date: Date(), data: 0.0)
    @Published var healthChartData = ChartData(values: [("", 0.0)])
    
    func getHealthData(type: HKQuantityTypeIdentifier, dateDistanceType: DateDistanceType, dateDistance: Int, completionHandler: @escaping ([HealthData]) -> Void) {
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
                        let value = quantity.is(compatibleWith: .percent()) ? quantity.doubleValue(for: .percent()) : quantity.is(compatibleWith: .count()) ? quantity.doubleValue(for: .count()) : quantity.is(compatibleWith: .inch()) ? quantity.doubleValue(for: .inch()) : quantity.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour()))
                        //data.append(UserData(id: UUID().uuidString, type: .Balance, title: type.rawValue, text: "", date: date, data: value))
                        
                        self.healthData.append(HealthData(id: UUID().uuidString, type: .Health, title: type.rawValue, text: "", date: date, data: value))
                        print(type.rawValue)
                        
                        
                    }
                    //  }
                }
                
            }
            
            completionHandler(data)
        }
        convertHealthDataToChart(healthData: healthData) { _ in
            
        }
        healthStore.execute(query3)
        
        
    }
    func convertHealthDataToChart(healthData: [HealthData], completionHandler: @escaping (ChartData) -> Void) {
        
        for data in healthData {
            healthChartData.points.append((data.type.rawValue,  data.data))
            
        }
        completionHandler(healthChartData)
    }
}

