//
//  CardView.swift
//  CardView
//
//  Created by Andreas on 8/18/21.
//

import SwiftUI

struct CardView: View {
    @State var card: Card
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color(uiColor: .systemGroupedBackground))
            
            HStack {
                Image(card.image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                VStack {
                    HStack {
                        Spacer()
                    Text(card.title)
                        .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                    }
                    HStack {
                        Spacer()
                    Text(card.description)
                        .font(.custom("Poppins-Bold", size: 14, relativeTo: .headline))
                }
                    HStack {
                        Spacer()
                    Button(action: card.action) {
                        Text(card.cta)
                    } .buttonStyle(CTAButtonStyle())
                        
                    }
                } .padding()
            }
        }
    }
}

