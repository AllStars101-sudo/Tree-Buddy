//
//  VirtualEconomyManager.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Combine

// MARK: - VirtualEconomyManager
// This class manages the virtual economy of the app.

class VirtualEconomyManager: ObservableObject {
    @Published var carbonCredits: Int = 0
    @Published var purchasedItems: Set<TreeAsset> = []
    @Published var showStore: Bool = false
    @Published var selectedStoreAsset: TreeAsset?
    
    // Prices (in Carbon Credits)
    let pricePine: Int = 20
    let priceBamboo: Int = 20
    let priceGrowthBooster: Int = 50
    
    // Purchase function.
    func purchase(item: StoreItem) -> Bool {
        if carbonCredits >= item.price {
            carbonCredits -= item.price
            if let asset = item.asset {
                purchasedItems.insert(asset)
            }
            return true
        }
        return false
    }
    
    func isPurchased(item: TreeAsset) -> Bool {
        purchasedItems.contains(item)
    }
}

// Represents a store item.
struct StoreItem: Identifiable {
    var id: String { name }
    let name: String
    let price: Int
    // For tree assets, provide an associated asset value.
    let asset: TreeAsset?
}
