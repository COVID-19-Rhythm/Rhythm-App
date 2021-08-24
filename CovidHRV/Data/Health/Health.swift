//
//  Health.swift
//  Health
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import HealthKit
import NiceNotifications

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
        
        backgroundDelivery()
    }
    func backgroundDelivery() {
        let readType2 = HKObjectType.quantityType(forIdentifier: .heartRate)
       
        healthStore.enableBackgroundDelivery(for: readType2!, frequency: .immediate) { success, error in
            if !success {
                print("Error enabling background delivery for type \(readType2!.identifier): \(error.debugDescription)")
            } else {
                print("Success enabling background delivery for type \(readType2!.identifier)")
                self.retrieveSleepAnalysis() { _ in
                self.getHealthData(type: .stepCount, dateDistanceType: .Week, dateDistance: 30, endDate: Date()) { value in
                self.getHealthData(type: .stepCount, dateDistanceType: .Week, dateDistance: 30, endDate: Date()) { value in
                  
                    for type in self.readData {
                        self.getHealthData(type: type, dateDistanceType: .Week, dateDistance: 30, endDate: Date()) { value in
                           
                        _ = self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: value)
        //            print(self.average(numbers: self.codableRisk.map{$0.risk}))
                }
                }
            }
                    if self.healthData.isEmpty {
                        
                    } else {
                        if  self.getRiskScore(bedTime: 0, wakeUpTime: 4, data: self.healthData).0.risk > 0.5 {
                            LocalNotifications.schedule(permissionStrategy: .askSystemPermissionIfNeeded) {
                                Today()
                                    .at(hour: Date().get(.hour), minute: Date().get(.minute) + 1)
                                    .schedule(title: "Significant Risk", body: "Your health data may indicate that you may be becoming sick")
                            }
                       // }

            }
                    }
                    }
                }
           
            
           
    }
    }
    }
    func convertSleepStartDate(StartDate: Date) -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd '18':'00':'01' +0000"
        let dateString = dateFormatter.string(from: StartDate)
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss +0000"
        let date = dateFormatter.date(from: dateString)
        let datePrior = Calendar.current.date(byAdding: .hour, value: -24, to: date!)
        print(datePrior as Any)

        return datePrior!
    }

    func convertSleepEndDate(EndDate: Date) -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd '17':'59':'59' +0000"
        let dateString = dateFormatter.string(from: EndDate)
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss +0000"
        let date = dateFormatter.date(from: dateString)
        print(date as Any)

        return date!
    }
   
    
    func retrieveSleepAnalysis(completionHandler: @escaping ([HealthData]) -> Void) {
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "inBed" : "asleep"
                            let newData = HealthData(id: UUID().uuidString, type: .Health, title: value, text: "", date: sample.startDate, data: sample.endDate.timeIntervalSince1970)
                            self.healthData.append(newData)
                           
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
                completionHandler(self.healthData)
            }
            
            // finally, we execute our query
            healthStore.execute(query)
        }
    }
    func calculateSleepHours(sample: HKSample) -> TimeInterval {

        let hours = sample.endDate.timeIntervalSince(sample.startDate) / 60 / 60

        return hours
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
                                                 options: [type == .stepCount ? .mostRecent : .discreteAverage],
                                                 anchorDate: anchorDate,
                                                 intervalComponents: interval as DateComponents)
        
        query3.initialResultsHandler = {
            query, results, error in
            
            if let statsCollection = results {
                
                
                
                statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                    //print(statsCollection.sources().first?.name)
                    
                    //if statsCollection.sources().last?.name == UIDevice.current.name {
                    //print(UIDevice.current.name)
                    if let quantity = (type == .stepCount ? statistics.mostRecentQuantity() : statistics.averageQuantity()) {
                       
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
       
            if !filteredToMoreThanZeroSteps.map({$0.date.get(.hour)}).contains(filteredToDay.last?.date.get(.hour))  {
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
            let lastNightAverage = self.average(numbers: todayHeartRates)
            let riskScore =  lastNightAverage > medianHeartrate + 4 ? 1 : lastNightAverage > medianHeartrate + 3 ? 0.5 : 0
        let explanation =  riskScore == 1 ? [Explanation(image: .exclamationmarkCircle, explanation: "Your health data may indicate you have an illness"), Explanation(image: .heart, explanation: "Calculated from your average heartrate while asleep"),  Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis, it's an alert to consult with your doctor")] : [Explanation(image: .checkmark, explanation: "Your health data may indicate you do not have an illness"), Explanation(image: .chartPie, explanation: "Calculated from your average heartrate while asleep"), Explanation(image: .stethoscope, explanation: "This is not a medical diagnosis or lack thereof, you may still have an illness")]
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

