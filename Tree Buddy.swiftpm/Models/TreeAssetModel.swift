//
//  TreeAssetModel.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Foundation

// MARK: - TreeAsset
// This enum represents the different tree species available in the app.

enum TreeAsset: String, CaseIterable, Identifiable, Codable {
    /*
      Bamboo Asset
      © Poly by Google via Poly Pizza, Licensed under CC BY 4.0.
      https://creativecommons.org/licenses/by/4.0/
      
      Bamboo by Poly by Google [CC-BY] via Poly Pizza
    */
    case oak, palm, maple, bamboo, pine
    
    var id: String { rawValue }
    
    // Asset file names for healthy tree models.
    var plantedAssetName: String {
        switch self {
        case .oak: return "oak.usdz"
        case .palm: return "palm.usdz"
        case .maple: return "maple.usdz"
        case .bamboo: return "bamboo.usdz"
        case .pine: return "pine.usdz"
        }
    }
    
    // Use the same dry asset for every tree.
    var dryAssetName: String { "treeDry.usdz" }
    
    // The assets for sapling and medium stages remain unchanged.
    var saplingAssetName: String { "sapling.usdz" }
    var mediumAssetName: String { "mediumTree.usdz" }
    
    // Scale Factors for each species and stage.
    // These values are used to size the models in AR.
    
    // For healthy models.
    var scaleSapling: Float {
        switch self {
        case .palm:
            return 0.010
        case .oak:
            return 0.015
        case .bamboo:
            return 0.012
        case .pine:
            return 0.013
        case .maple:
            return 0.014
        }
    }
    
    var scaleMedium: Float {
        switch self {
        case .palm:
            return 0.003
        case .oak:
            return 0.003
        case .bamboo:
            return 0.04
        case .pine:
            return 0.0028
        case .maple:
            return 0.028
        }
    }
    
    var scaleFull: Float {
        switch self {
        case .palm:
            return 0.007
        case .oak:
            return 0.006
        case .bamboo:
            return 0.1
        case .pine:
            return 0.005
        case .maple:
            return 0.045
        }
    }
    
    // These values are independent of the healthy scales and much smaller.
    var scaleSaplingDry: Float { 0.0007 }
    var scaleMediumDry: Float { 0.0009 }
    var scaleFullDry: Float { 0.003 }
    
    // Emoji representation for the selection pane.
    var emoji: String {
        switch self {
        case .pine: return "🌲"
        case .palm: return "🌴"
        case .oak: return "🌳"
        case .bamboo: return "🎍"
        case .maple: return "🍁"
        }
    }
}
