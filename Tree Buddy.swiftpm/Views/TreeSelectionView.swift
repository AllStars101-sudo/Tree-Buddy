//
//  TreeSelectionView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - TreeSelectionView
// This view displays a grid of tree assets available for selection.
// If the user has not purchased a tree, the store view is presented when tapped.

struct TreeSelectionView: View {
    @Binding var isPresented: Bool
    @ObservedObject var treeVM: TreeViewModel
    @ObservedObject var economy: VirtualEconomyManager
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(TreeAsset.allCases) { asset in
                        Button {
                            // Present store if tree is locked.
                            if (asset == .pine || asset == .bamboo), !economy.isPurchased(item: asset) {
                                withAnimation {
                                    economy.selectedStoreAsset = asset
                                    economy.showStore = true
                                }
                            } else {
                                withAnimation(.spring()) {
                                    treeVM.selectedTreeAsset = asset
                                }
                                isPresented = false
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 120)
                                
                                VStack(spacing: 8) {
                                    Text(asset.emoji)
                                        .font(.system(size: 50))
                                    Text(asset.rawValue.capitalized)
                                        .font(.caption)
                                }
                                .padding()
                                // Lock and checkmark icons.
                                if (asset == .pine || asset == .bamboo),
                                   !economy.isPurchased(item: asset) {
                                    Color.black.opacity(0.4)
                                        .cornerRadius(15)
                                    Image(systemName: "lock.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .transition(.opacity.animation(.easeInOut))
                                }
                                else if treeVM.selectedTreeAsset == asset {
                                    Color.green.opacity(0.3)
                                        .cornerRadius(15)
                                        .transition(.opacity.animation(.easeInOut))
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                        .transition(.opacity.animation(.easeInOut))
                                }
                            }
                        }
                        .accessibilityLabel("\(asset.rawValue.capitalized) tree")
                        .accessibilityHint((asset == .pine || asset == .bamboo) && !economy.isPurchased(item: asset) ? "Locked. Tap to open store" : "Tap to select this tree")
                    }
                }
                .padding()
            }
            .navigationTitle("Select Your Tree")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Tap to close tree selection")
                }
            }
        }
        .sheet(isPresented: $economy.showStore) {
            StoreView(economy: economy, treeVM: treeVM)
        }
    }
}

