//
//  HomeView.swift
//  HomeView
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI

struct HomeView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    @State var gridLayout: [GridItem] = [ ]
    @ObservedObject var health: Health
    @State var enrolled = UserDefaults.standard.bool(forKey: "enrolled")
    var body: some View {
        NavigationView {
        ScrollView {
            LazyVGrid(columns: gridLayout) {
                
                RiskCardView(health: health)
                FeelingScoreInputView(health: health)
                    .padding()
                if !enrolled {
                CardView(card: Card( image: "doc", title: "CTA", description: "CTA description", cta: "CTA"))
                    .padding()
                }
                //BarChartView(data: $health.healthChartData, title: "Score", legend: "")
            }
        } .navigationTitle("")
                .navigationBarHidden(true)
        .onAppear() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                print("iPad")
                self.gridLayout = [GridItem(), GridItem(.flexible())]
            } else {
                self.gridLayout =  [GridItem(.flexible())]
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
            if UIDevice.current.userInterfaceIdiom == .phone {
                if !orientation.isFlat {
                    self.gridLayout = (orientation.isLandscape) ? [GridItem(), GridItem(.flexible())] :  [GridItem(.flexible())]
                }
            }
        }
        }
    }
}

