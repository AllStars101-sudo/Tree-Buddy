//
//  BadgeModel.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Foundation

// MARK: - Badge
// This struct represents a badge that can be earned by the user.

struct Badge: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let imageName: String
}

// MARK: - Badge extension
// This extension provides sample badges and a method to check if a badge has been achieved.

extension Badge {
    static let sampleBadges: [Badge] = [
        Badge(title: "Green Thumb",
              description: "Planted your first tree!",
              imageName: "leaf.fill"),
        Badge(title: "Forest Forager",
              description: "Planted 5 trees!",
              imageName: "sparkles"),
        Badge(title: "CO₂ Crusader",
              description: "Reduced 100 kg CO₂!",
              imageName: "aqi.medium"),
        Badge(title: "Forest Guardian",
              description: "Grew a thriving forest!",
              imageName: "checkmark.seal.fill"),
        Badge(title: "Eco Warrior",
              description: "Planted 20 trees!",
              imageName: "globe.asia.australia.fill"),
        Badge(title: "Nature Protector",
              description: "Reduced 500 kg CO₂!",
              imageName: "shield.lefthalf.fill"),
        Badge(title: "Tree Hugger",
              description: "Watered a tree 10 times in one day!",
              imageName: "hand.raised.fill"),
        Badge(title: "Seed Sower",
              description: "Planted 3 trees within a minute!",
              imageName: "sparkles"),
        Badge(title: "Eco Innovator",
              description: "Used growth accelerator 5 times!",
              imageName: "bolt.circle.fill")
    ]
    
    // Returns whether this badge has been achieved based on TreeBuddy’s metrics.
    func isAchieved(by treeVM: TreeViewModel) -> Bool {
        switch self.title {
        case "Green Thumb":
            return treeVM.trees.count >= 1
        case "Forest Forager":
            return treeVM.trees.count >= 5
        case "CO₂ Crusader":
            return treeVM.totalCO2Reduction >= 100
        case "Forest Guardian":
            return treeVM.trees.count >= 10 || treeVM.totalCO2Reduction >= 200
        case "Eco Warrior":
            return treeVM.trees.count >= 20
        case "Nature Protector":
            return treeVM.totalCO2Reduction >= 500
        case "Tree Hugger":
            return treeVM.trees.contains { $0.waterCountToday >= 10 }
        case "Seed Sower":
            // If three or more trees were planted within the last 60 seconds.
            let recentTrees = treeVM.trees.filter {
                Date().timeIntervalSince($0.plantedDate) < 60
            }
            return recentTrees.count >= 3
        case "Eco Innovator":
            let accelCount = treeVM.trees.filter { $0.accelerateStartTime != nil }.count
            return accelCount >= 5
        default:
            return false
        }
    }
}
