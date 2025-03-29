//
//  CarbonCreditsBox.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - CarbonCreditsBox
// This view displays the combined pool of carbon credits from the tree and economy view models.
// It also provides a button to open the Carbon Store.

struct CarbonCreditsBox: View {
    @ObservedObject var treeVM: TreeViewModel
    @ObservedObject var economy: VirtualEconomyManager
    @State private var showStore: Bool = false

    // Create an instance of CarbonStoreTip
    let carbonStoreTip = CarbonStoreTip()    
    
    // Computes the combined pool of credits.
    var totalCredits: Int {
        treeVM.carbonCredits + economy.carbonCredits
    }
    
    var body: some View {
        Button {
            showStore = true
            // Invalidate the tip once the user taps the button.
            carbonStoreTip.invalidate(reason: .actionPerformed)
        } label: {
            // Carbon Credits box with total credits.
            HStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("\(totalCredits) Credits")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        // Attach the CarbonStoreTip as a popover tip to this button.
        .popoverTip(carbonStoreTip)
        .padding(.leading)
        .padding(.top, 4)
        .accessibilityLabel("Carbon Credits")
        .accessibilityHint("Tap to open the Carbon Store")
        .sheet(isPresented: $showStore) {
            StoreView(economy: economy, treeVM: treeVM)
                .presentationDetents([.large])
        }
    }
}
