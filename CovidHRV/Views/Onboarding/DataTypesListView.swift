//
//  DataTypesListView.swift
//  DataTypesListView
//
//  Created by Andreas on 8/20/21.
//

import SwiftUI

struct DataTypesListView: View {
    @State var explanations = [Explanation(image: .heart, explanation: "Heart Rate"), Explanation(image: .person, explanation: "Steps"), Explanation(image: .lungs, explanation: "Respiratory Rate"), Explanation(image: .oCircle, explanation: "Oxygen Saturation")]
    @State var descriptions = ["Needed to detect irregularly high heart rate while asleep.", "Used to omit data taken at night while your still active.", "Monitors for high breathing rates while asleep.", "Needed to detect low oxygen in blood."]
    var body: some View {
        VStack {
            ForEach(explanations.indices, id:\.self) { i in
                HStack {
                    
                    Image(systemSymbol: explanations[i].image)
                        .font(.title)
                Text(explanations[i].explanation)
                    .font(.custom("Poppins-Bold", size: 20, relativeTo: .headline))
                    Spacer()
                }
                HStack {
                    
                Text(descriptions[i])
                    .font(.custom("Poppins", size: 16, relativeTo: .headline))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top)
                    Spacer()
                }
                Divider()
            }
        } .padding()
    }
}

struct DataTypesListView_Previews: PreviewProvider {
    static var previews: some View {
        DataTypesListView()
    }
}
