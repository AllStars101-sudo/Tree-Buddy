//
//  Tips.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import TipKit

// MARK: - Tips
// This file contains the tip definitions for the app.

// Tip for selecting a tree species.
struct SelectingTreeTip: Tip {
    // This parameter ensures the tip is shown only after onboarding is completed.
    @Parameter
    static var onboardingDone: Bool = false
    
    var title: Text {
        Text("Select a Tree")
            .foregroundStyle(.indigo)
    }
    
    var message: Text? {
        Text("Tap this button to choose a different tree species for your forest.")
    }
    
    // Providing an icon for the tip.
    var image: Image? {
        Image(systemName: "tree.fill")
    }
    
    var rules: [Rule] {
        // Only display the tip after onboarding is complete.
        #Rule(Self.$onboardingDone) {
            $0 == true
        }
    }
}

// Tip for visiting the Carbon Store.
struct CarbonStoreTip: Tip {
    @Parameter
    static var onboardingDone: Bool = false
    
    var title: Text {
        Text("Visit Carbon Store")
            .foregroundStyle(.green)
    }
    
    var message: Text? {
        Text("Tap here to spend your carbon credits on tree upgrades and boosters!")
    }
    
    // Add an icon for the tip.
    var image: Image? {
        Image(systemName: "storefront.fill")
    }
    
    var rules: [Rule] {
        // Only show the tip when onboarding is complete.
        #Rule(Self.$onboardingDone) { $0 == true }
    }
}
