//
//  Health.swift
//  Health
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
class Health: ObservableObject {
    @Published var codableRisk = [CodableRisk(id: UUID().uuidString, date: Date(), risk: 0.0, explanation: [String]())]
    @Published var healthStore = HKHealthStore()
    @Published var risk = Risk(id: "", risk: 0.2, explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Explain it here!!"), Explanation(image: .questionmarkCircle, explanation: "Explain it here?"), Explanation(image: .circle, explanation: "Explain it here.")])
//    @Published var readData: [HKQuantityTypeIdentifier] =  [.heartRateVariabilitySDNN,
//                                                            .restingHeartRate,
//                                                            .walkingHeartRateAverage,
//                                                            .heartRate,
//                                                            .walkingSpeed,
//                                                            .respiratoryRate, .oxygenSaturation]
    @Published var readData: [HKQuantityTypeIdentifier] =  [.heartRate]//, .stepCount]
    @Published var healthData = [HealthData]()
    @Published var tempHealthData = HealthData(id: UUID().uuidString, type: .Feeling, title: "", text: "", date: Date(), data: 0.0)
    @Published var healthChartData = ChartData(values: [("", 0.0)])
    @Published var todayHeartRate = [HealthData]()
    init() {
//        backgroundDelivery()
//        for type in readData {
//            getHealthData(type: type, dateDistanceType: .Week, dateDistance: 30, endDate: Date() - (3600*24)) { value in
//            //_ = self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: value)
//           // print(self.average(numbers: self.codableRisk.map{$0.risk}))
//        }
//        }
        for type in readData {
            getHealthData(type: type, dateDistanceType: .Week, dateDistance: 30, endDate: Date()) { value in
              
                _ = self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: value)
//            print(self.average(numbers: self.codableRisk.map{$0.risk}))
        }
    }
    }
    func getHealthData(type: HKQuantityTypeIdentifier, dateDistanceType: DateDistanceType, dateDistance: Int, endDate: Date, completionHandler: @escaping ([HealthData]) -> Void) {
        
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
                        if type == .heartRate {
                        print(date)
                        }
                        
                        
                    }
                    //  }
                }
                
            }
            
            completionHandler(data)
        }
            self.convertHealthDataToChart(healthData: self.healthData) { _ in
            
        }
           
            self.healthStore.execute(query3)
        
        }
       
    }

    func getRiskScore(bedTime: Int, wakeUpTime: Int, data: [HealthData]) -> (Risk, [CodableRisk]) {
        //DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
        print("Calculating Risk...")
        if !healthData.isEmpty {
        var medianHeartrate = 0.0
            let url3 = self.getDocumentsDirectory().appendingPathComponent("risk.txt")
        do {
            
            let input = try String(contentsOf: url3)
            
            
            let jsonData = Data(input.utf8)
            do {
                let decoder = JSONDecoder()
                
                do {
                    let codableRisk = try decoder.decode([CodableRisk].self, from: jsonData)
                    
                   // medianHeartrate = codableRisk.map{Int($0.risk)}.median()
                    
                 
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
        let filteredToSteps = filteredToNight.filter {
            return $0.title == HKQuantityTypeIdentifier.stepCount.rawValue
        }
        let filteredToMoreThanZeroSteps = filteredToSteps.filter {
            return $0.data != 0
        }
        var todayHeartRates = [Double]()
        var heartRates = [Double]()
        var averageHRPerNight = [Double]()
        var dates = [Date]()
        print(healthData.map{$0.date})
        for day in 0...30 {
        let filteredToDay = filteredToHeartRate.filter { data in
            return data.date.get(.day) == day && data.date.get(.month) == Date().get(.month)
        }
            heartRates = []
            print(filteredToDay)
       
            if !filteredToMoreThanZeroSteps.map({$0.date}).contains(filteredToDay.last?.date ?? Date()) {
                if !filteredToDay.isEmpty {
                    if Date().get(.day) == day {
                        todayHeartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                    } else {
                        heartRates.append(filteredToDay.isEmpty ? filteredToDay.last?.data ?? 0.0 : average(numbers: filteredToDay.map{$0.data}))
                    }
                
                    
            dates.append(filteredToDay.last?.date ?? Date())
                }
            
        }
            if !heartRates.isEmpty {
                averageHRPerNight.append(average(numbers: heartRates))
            }
        }
       print("averageHRPerNight")
       print(averageHRPerNight)
        medianHeartrate = averageHRPerNight.median()
            let riskScore = self.average(numbers: todayHeartRates) > medianHeartrate + 3 ? 1 : 0
        let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep"),  Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, its an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
        let risk = Risk(id: UUID().uuidString, risk: CGFloat(riskScore), explanation: explanation)
        #warning("Change to a highher value to prevent bad data (because of low amount of data)")
        if averageHRPerNight.count > 0 {
        withAnimation(.easeOut(duration: 1.3)) {
            
        self.risk = risk
        }
            self.codableRisk.append(CodableRisk(id: risk.id, date: dates.last ?? Date(), risk: risk.risk, explanation: [String]()))
        } else {
            self.risk = Risk(id: "NoData", risk: CGFloat(21), explanation: [Explanation(image: .exclamationmarkCircle, explanation: "Wear your Apple Watch as you sleep to see your data")])
        }
            //print(self.codableRisk)
        }
       
        //}
        return (self.risk, codableRisk)
    }
    func average(numbers: [Double]) -> Double {
       // print(numbers)
       return Double(numbers.reduce(0,+))/Double(numbers.count)
   }
    func convertHealthDataToChart(healthData: [HealthData], completionHandler: @escaping (ChartData) -> Void) {
        
        for data in healthData {
            healthChartData.points.append((data.type.rawValue,  data.data*10))
            
        }
        completionHandler(healthChartData)
    }
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}

