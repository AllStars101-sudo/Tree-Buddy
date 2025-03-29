//
//  GameCenterManager.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Foundation
import GameKit

// MARK: - GameCenterManager
// This class manages Game Center authentication and score reporting.
// It is an ObservableObject that publishes the isAuthenticated property.
// This really is just a placeholder function for the actual implementation.

final class GameCenterManager: NSObject, ObservableObject {
    @Published var isAuthenticated: Bool = false
    static let shared = GameCenterManager()
    
    override init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                // Present the Game Center sign‑in view from the root view controller.
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    rootVC.present(viewController, animated: true)
                }
            } else if localPlayer.isAuthenticated {
                DispatchQueue.main.async {
                    self?.isAuthenticated = true
                }
            } else {
                DispatchQueue.main.async {
                    self?.isAuthenticated = false
                }
                if let error = error {
                    print("Game Center authentication error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Report the number of trees planted to the leaderboard.
    func reportTreePlanted(count: Int) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(
            Int(count),
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: ["leaderboard.treesPlanted"],
            completionHandler: { error in
                if let error = error {
                    print("Error reporting trees planted score: \(error.localizedDescription)")
                } else {
                    print("Successfully reported trees planted score: \(count)")
                }
            }
        )
    }
    
    // Report the CO₂ offset to the leaderboard.
    func reportCO2Offset(co2Offset: Double) {
        guard isAuthenticated else { return }
        let scoreValue = Int(co2Offset * 100)
        GKLeaderboard.submitScore(
            scoreValue,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: ["leaderboard.co2Offset"],
            completionHandler: { error in
                if let error = error {
                    print("Error reporting CO₂ offset score: \(error.localizedDescription)")
                } else {
                    print("Successfully reported CO₂ offset score: \(co2Offset)")
                }
            }
        )
    }
}
