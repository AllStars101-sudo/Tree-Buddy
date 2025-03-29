//
//  TreeModel.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import simd
import Foundation

// MARK: - TreeModel
// This struct represents a tree model.
// It includes properties for tracking the tree's growth, health, and watering status.

enum TreeGrowthStage: Int, CaseIterable, Codable {
    case sapling, medium, full
}

enum TreeHealth: String, Codable {
    case healthy, dry
}

struct TreeModel: Identifiable, Codable {
    var id: UUID = UUID()
    var stage: TreeGrowthStage = .sapling
    var health: TreeHealth = .healthy
    var plantedDate: Date = Date()
    var lastWatered: Date = Date()
    var waterCountToday: Int = 0
    var lastWaterDate: Date = Date()
    var fullGrownDate: Date? = nil  // Record the time when a tree reaches full growth.
    
    // Accelerated growth properties.
    var accelerateStartTime: Date? = nil
    var accelerationBaseProgress: Double = 0.0
    var growthProgress: Double = 0.0  // Value in [0,1]
    
    // Asset associated with this tree.
    var asset: TreeAsset = .maple
    
    // Default name.
    var name: String = ""
    
    // Flag to ensure the app plays the "dry" sound only once per drying event.
    var hasPlayedDrySound: Bool = false
    
    func isDry(currentDate: Date, dryThreshold: TimeInterval) -> Bool {
        currentDate.timeIntervalSince(lastWatered) > dryThreshold
    }
    
    // Returns the appropriate asset name based on the current growth stage and health.
    func assetName() -> String {
        if health == .dry {
            return asset.dryAssetName
        }
        switch stage {
        case .sapling:
            return asset.saplingAssetName
        case .medium:
            return asset.plantedAssetName
        case .full:
            return asset.plantedAssetName
        }
    }
    
    // Returns the target scale for the current stage and health.
    func targetScale() -> Float {
        let isDry = (health == .dry)
        switch stage {
        case .sapling:
            return isDry ? asset.scaleSaplingDry : asset.scaleSapling
        case .medium:
            return isDry ? asset.scaleMediumDry : asset.scaleMedium
        case .full:
            return isDry ? asset.scaleFullDry : asset.scaleFull
        }
    }
}
