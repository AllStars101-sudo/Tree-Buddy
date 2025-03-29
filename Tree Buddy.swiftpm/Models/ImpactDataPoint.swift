//
//  ImpactDataPoint.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Foundation

// MARK: - ImpactDataPoint
// This struct represents a data point for the impact of a tree.

struct ImpactDataPoint: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let value: Double
}
