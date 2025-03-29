//
//  LeaderboardSelectionView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - LeaderboardSelectionView
// This view displays a segmented control to select between two leaderboards.
// This does not work in Swift Playgrounds due to Game Center restrictions.

struct LeaderboardSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedIndex = 0
    // Replace these strings with your actual leaderboard identifiers.
    let leaderboardIDs = [
        "leaderboard.treesPlanted",
        "leaderboard.co2Offset"
    ]
    
    // This simple flag checks if we're running in a playground.
    private var isPlayground: Bool {
        return (NSClassFromString("PlaygroundRemoteLiveViewProxy") != nil) ||
        (NSClassFromString("PlaygroundPage") != nil)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Show an inline message explaining leaderboards do not work in Swift Playgrounds.
                Text("⚠️ Leaderboards do not work in Swift Playgrounds. ⚠️\n In a real Xcode project, the user would've been prompted by Game Center to access leaderboard and friends.")
                    .font(.footnote)
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(8)
                    .padding()
                
                Picker("Leaderboard", selection: $selectedIndex) {
                    Text("Trees Planted").tag(0)
                    Text("CO₂ Offset").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                Spacer()
                Text("Game Center functionality is disabled in Swift Playgrounds.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
                
                // Otherwise, display the Game Center leaderboard view.
                GameCenterLeaderboardView(leaderboardID: leaderboardIDs[selectedIndex])
                    .ignoresSafeArea()
            }
            .navigationTitle("Leaderboards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
