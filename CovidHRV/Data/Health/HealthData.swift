//
//  HealthData.swift
//  HealthData
//
//  Created by Andreas on 8/17/21.
//

import SwiftUI
import SFSafeSymbols
struct HealthData: Identifiable, Codable, Hashable {
    var id: String
    var type: DataType
    var title: String
    var text: String
    var date: Date
    var data: Double

    
    
}
enum DataType: String, Codable, CaseIterable {
    case HRV = "HRV"
    case Health = "Health"
    case Feeling = "Feeling"
    
}

struct CodableRisk: Identifiable, Codable, Hashable {
    var id: String
    var risk: CGFloat
    var explanation: [String]
}
struct Risk: Hashable {
    var id: String
    var risk: CGFloat
    var explanation: [Explanation]
}
struct Explanation: Hashable {
    var image: SFSymbol
    var explanation: String
}
