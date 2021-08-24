//
//  RiskCardView.swift
//  RiskCardView
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI
import SFSafeSymbols
struct RiskCardView: View {
    @ObservedObject var health: Health
    @State var min: CGFloat = UserDefaults.standard.double(forKey: "minRisk")
    @State var max: CGFloat = UserDefaults.standard.double(forKey: "maxRisk")
    @State var explain = true
    @State var learnMore = false
    @State var openData = false
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: DataView(health: health)) {
                 
                    Image(systemSymbol: .chartBar)
                        .font(.title)
                        
                }
                
               
                Text("Covid Risk Score")
                    .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                Spacer()
                Button(action: {
                    withAnimation(.easeOut) {
                    explain.toggle()
                    }
                }) {
                    Image(systemSymbol: .questionmarkCircle)
                        .font(.largeTitle)
                }
            }
            
        HalvedCircularBar(progress: $health.risk.risk, min: $min, max: $max)
                .padding(.top)
            
                
               
                
            if explain {
                ZStack {
                    Color(uiColor: .systemBackground)
                    VStack {
                //LazyVGrid(columns: [GridItem(), GridItem()]) {
                        VStack {
                ForEach(health.risk.explanation, id: \.self) { value in
                    
                    HStack {
                       
                        Image(systemSymbol: value.image)
                            .foregroundColor(Color(value.explanation == "Your health data may indicate you have an illness" ? "red" : "text"))
                        Text(value.explanation)
                        
                            .foregroundColor(Color(value.explanation == "Your health data may indicate you have an illness" ? "red" : "text"))
                    .font(.custom("Poppins-Bold", size: 16, relativeTo: .headline))
                        Spacer()
                    }
                .padding(.top)
                    Divider()
                }
                } .transition(.move(edge: .top))
                Button(action: {
                    learnMore.toggle()
                }) {
                    Text("Learn More")
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                } .transition(.move(edge: .top))
            }
                }
            }
        } .padding()
            .onAppear() {
                min = (health.codableRisk.map{$0.risk}.min() ?? 0)*0.705
                max = (health.codableRisk.map{$0.risk}.max() ?? 0)*0.705
            }
    }
}

import SwiftUI

struct HalvedCircularBar: View {
    
    @Binding var progress: CGFloat
    @Binding var min: CGFloat
    @Binding var max: CGFloat
    var body: some View {
        VStack {
            if progress != 21 {
            ZStack {
                
                Circle()
                    .trim(from: 0.0, to: 0.705)
                    .stroke(Color(progress > 0.8 ? "red" : "green"), lineWidth: 20)
                    .opacity(0.4)
                    .frame(width: 200, height: 200)
                    .rotationEffect(Angle(degrees: -215))
                Circle()
                    .trim(from: min, to: max)
                    .stroke(Color(progress > 0.8 ? "red" : "green"), lineWidth: 20)
                    .frame(width: 200, height: 200)
                    .rotationEffect(Angle(degrees: -215))
               
                Text(progress == 21 ? "Not Enough Data" : "\(Int((self.progress)*100))%")
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                    .foregroundColor(Color(progress > 0.8 ? "red" : "green"))
                
                VStack {
                    Spacer()
                    HStack {
                        Text("0")
                            .font(.custom("Poppins", size: 12, relativeTo: .headline))
                        Spacer()
                        Text("100")
                            .font(.custom("Poppins", size: 12, relativeTo: .headline))
                   
                    } .padding(.horizontal, 105)
                    
                } .padding(.bottom)
                
            } .onAppear() {
                
//                min = min*0.705
//                max = max*0.705
               
            }
            } else {
                Text(progress == 21 ? "Not Enough Data" : "\(Int((self.progress)*100))%")
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                    .foregroundColor(Color("red"))
            }
        }
    }
    
  
}
