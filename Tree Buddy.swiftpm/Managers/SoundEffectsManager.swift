//
//  SoundEffectsManager.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Foundation
import AVFoundation

enum SoundEffect: String, CaseIterable {
    case treePlanted = "tree_planted"
    case treeWatered = "water_splash"
    case itemPurchased = "purchase_success"
    case treeDry = "tree_dry"
    case badgeEarned = "badge_earned"
    case waterReminder = "water_reminder"
    case accelerateGrowth = "accelerate_growth"
}

final class SoundEffectsManager: ObservableObject {
    static let shared = SoundEffectsManager()
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    
    private init() {
        preloadSounds()
    }
    
    private func preloadSounds() {
        for effect in SoundEffect.allCases {
            if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3")
                ?? Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    players[effect] = player
                } catch {
                    print("Error loading sound effect \(effect.rawValue): \(error.localizedDescription)")
                }
            } else {
                print("Sound file \(effect.rawValue) not found in bundle.")
            }
        }
    }
    
    func play(_ effect: SoundEffect) {
        // Play on a background thread to avoid blocking the main thread.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.players[effect]?.play()
        }
    }
}
