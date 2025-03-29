//
//  TreeBuddy.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import TipKit

// MARK: - TreeBuddy
// The main entry point for the app.

@main
struct TreeBuddy: App {
    init() {
        do {
            // For production, remove/reset calls as needed.
            try Tips.configure()
            // In a real Xcode project, this would be commented to avoid repeated tips.
            try Tips.resetDatastore()
        } catch {
            print("Error initializing tips: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
