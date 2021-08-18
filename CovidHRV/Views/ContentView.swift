//
//  ContentView.swift
//  CovidHRV
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var health = Health()
    var body: some View {
        HomeView(health: health)
            .onAppear() {
                for type in health.readData {
                health.getHealthData(type: type, dateDistanceType: .Week, dateDistance: 2) { _ in
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
