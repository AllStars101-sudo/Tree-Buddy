//
//  StoreView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - StoreItem
// Represents an item available in the Carbon Store.

struct StoreView: View {
    @ObservedObject var economy: VirtualEconomyManager
    @ObservedObject var treeVM: TreeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showInsufficientCreditsAlert: Bool = false
    
    // Store items available for purchase.
    var storeItems: [StoreItem] {
        [
            StoreItem(name: "Pine Tree", price: economy.pricePine, asset: .pine),
            StoreItem(name: "Bamboo", price: economy.priceBamboo, asset: .bamboo),
            StoreItem(name: "Growth Booster", price: economy.priceGrowthBooster, asset: nil)
        ]
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Carbon Credits: \(treeVM.carbonCredits + economy.carbonCredits)")
                    .font(.headline)
                    .padding(.horizontal)
                    .accessibilityLabel("Carbon Credits")
                    .accessibilityValue("\(treeVM.carbonCredits + economy.carbonCredits) credits")
                
                ForEach(storeItems) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.title3.bold())
                            
                            // For Growth Booster, show a subtitle.
                            if item.name == "Growth Booster" {
                                Text("Reduces the growth time for trees from 10 days to 5.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Credits text beside the Buy button.
                        Text("\(item.price) Credits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button {
                            // Check if sufficient credits are available.
                            if (treeVM.carbonCredits + economy.carbonCredits) >= item.price {
                                if item.name == "Growth Booster" {
                                    // Use currentTree; if none is selected, use the first tree.
                                    let treeToBoost = treeVM.currentTree() ?? treeVM.trees.first
                                    if let tree = treeToBoost {
                                        treeVM.applyGrowthBooster(to: tree)
                                    }
                                    deductCredits(amount: item.price)
                                } else {
                                    deductCredits(amount: item.price)
                                    if let asset = item.asset {
                                        economy.purchasedItems.insert(asset)
                                    }
                                }
                                SoundEffectsManager.shared.play(.itemPurchased)
                            } else {
                                showInsufficientCreditsAlert = true
                            }
                        } label: {
                            Text("Buy")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color.accentColor.opacity(0.2), in: Capsule())
                        }
                        .accessibilityLabel("Buy \(item.name)")
                        .accessibilityHint("Costs \(item.price) credits")
                        // Growth Booster is always enabled; for others, disable if already purchased.
                        .disabled(item.name != "Growth Booster" &&
                                  economy.isPurchased(item: item.asset!))
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                }
                Spacer()
            }
            .navigationTitle("Carbon Store")
            .accessibilityElement(children: .contain)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityLabel("Done")
                        .accessibilityHint("Tap to close the store")
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .alert("Insufficient Credits", isPresented: $showInsufficientCreditsAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Sorry, you don't have enough carbon credits. Earn more by planting trees, watering them, and unlocking badges in your impact feed.")
        }
    }
    
    // Deducts the specified amount of credits from the tree and economy.
    private func deductCredits(amount: Int) {
        var remaining = amount
        if treeVM.carbonCredits >= remaining {
            treeVM.carbonCredits -= remaining
            remaining = 0
        } else {
            remaining -= treeVM.carbonCredits
            treeVM.carbonCredits = 0
        }
        if remaining > 0 {
            economy.carbonCredits -= remaining
        }
    }
}
