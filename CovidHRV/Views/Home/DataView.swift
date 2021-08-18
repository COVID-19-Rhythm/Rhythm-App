////
////  DataView.swift
////  DataView
////
////  Created by Andreas on 8/18/21.
////
//
import SwiftUI

struct DataView: View {
    @State private var date = Date()
    @State private var average = 0.0
    @ObservedObject var health: Health
    @State var data = ChartData(values: [("", 0.0)])
    var body: some View {
        
        VStack {
            HStack {
                Text("Average: " + String(average))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
                .onAppear() {
                    loadData  { (score) in
                        average = health.average(numbers: health.healthData.filter { data in
                            return data.type == .Health && data.data != 21
                        }.map{$0.data})
                        
                    }
                    let maximum =  ChartData(values: [("", 0.0)])
                    let filtered2 = data.points.filter { word in
                        return word.0 != "NA"
                    }
                   
                    let average2 = health.average(numbers: filtered2.map {$0.1})
                    let minScore = filtered2.map {$0.1}.max()
                    let filtered = filtered2.filter { word in
                        return word.1 == minScore
                    }
                    
                    if average2.isNormal {
                        maximum.points.append((String("Average"), average2))
                        maximum.points.append((String(filtered.last?.0 ?? "") , filtered.last?.1 ?? 0.0))
                       //max = maximum
//                        maxText = "At \(max.points.last?.0 ?? "") your score was higher than any other hour today."
//
                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        withAnimation(.easeInOut) {
//                            refresh = false
//                        }
//
//                    }
                }
            
            }
                //.opacity(isTutorial ? (tutorialNum == 1 ? 1.0 : 0.1) : 1.0)
                .onChange(of: date, perform: { value in
                    
                    //refresh = true
                    loadData  { (score) in
                        let numbers = health.healthData.filter { data in
                            return data.type == .Risk && data.data != 21
                        }.map{$0.data}
                        print(numbers)
                        average = health.average(numbers: numbers)

                    }
                    let maximum =  ChartData(values: [("", 0.0)])
                   
                    let filtered2 = data.points.filter { word in
                        return word.0 != "NA"
                    }
                   
                    let average2 = health.average(numbers: filtered2.map {$0.1})
                    let minScore = filtered2.map {$0.1}.max()
                    let filtered = filtered2.filter { word in
                        return word.1 == minScore
                    }
                    
                    if average2.isNormal {
                        maximum.points.append((String("Average"), average2))
                        maximum.points.append((String(filtered.last?.0 ?? "") , filtered.last?.1 ?? 0.0))
                        //max = maximum
                       //// maxText = "At \(max.points.last?.0 ?? "") your score was higher than any other hour today."
                        
                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        withAnimation(.easeInOut) {
//                            refresh = false
//                        }
//
//                    }
                })
            HStack {
                Text("Total Score")
                    .font(.custom("Poppins-Bold", size: 24, relativeTo: .headline))
                Spacer()
            }  //.opacity(isTutorial ? (tutorialNum == 2 ? 1.0 : 0.1) : 1.0)
            
                
            BarChartView(data: $data, title: "Covid Risk Score")
            Text("1 indicates poorer health while a 0 indicates a healthier condition")
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                //.opacity(isTutorial ? (tutorialNum == 2 ? 1.0 : 0.1) : 1.0)
            
//            if max.points.last?.1 != max.points.first?.1 {
//                DayChartView(title: "Score", chartData: $max, refresh: $refresh, dataTypes: $dataTypes, userData: $userData)
//                Text(maxText)
//                    .multilineTextAlignment(.leading)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
//            }
            
           
            Spacer()
        } .padding()
           
        }
    
    func loadData( completionHandler: @escaping (String) -> Void) {
       
        data = ChartData(values: [("", 0.0)])
        
        
        let filtered = health.healthData.filter { data in
            return data.date.get(.weekOfYear) == date.get(.weekOfYear) && date.get(.year) == data.date.get(.year)
        }
        
        let scorePoints = ChartData(values: [("", 0.0)])
        
        for day in 0...7 {
            
       
            let filteredDay = filtered.filter { data in
                return data.date.get(.hour) == day
            }
            let risk = filteredDay.filter { data in
                return  data.type == .Risk
            }
        
            
            

            var scores = [Double]()
            
            let averageScore =  health.average(numbers: risk.map{$0.data})
        
            scorePoints.points.append(("\(DayOfWeek.init(rawValue: day) ?? .Monday)", averageScore))
            
            
           
           
 
            self.data = scorePoints
        
        }
    }
    }

//struct DataView_Previews: PreviewProvider {
//    static var previews: some View {
//        DataView()
//    }
//}
