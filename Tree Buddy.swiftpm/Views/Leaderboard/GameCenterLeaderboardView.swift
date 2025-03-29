//
//  GameCenterLeaderboardView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import GameKit

// MARK: - GameCenterLeaderboardView
// This view displays a Game Center leaderboard.
// This does not work in Swift Playgrounds due to Game Center restrictions.

struct GameCenterLeaderboardView: UIViewControllerRepresentable {
    var leaderboardID: String
    
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let gcViewController = GKGameCenterViewController(
            leaderboardID: leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        gcViewController.gameCenterDelegate = context.coordinator
        return gcViewController
    }
    
    func updateUIViewController(_ uiViewController: GKGameCenterViewController,
                                context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        func gameCenterViewControllerDidFinish(
            _ gameCenterViewController: GKGameCenterViewController
        ) {
            gameCenterViewController.dismiss(animated: true)
        }
    }
}
