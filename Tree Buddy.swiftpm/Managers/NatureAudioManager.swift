//
//  NatureAudioManager.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import AVFoundation

// MARK: - NatureAudioManager
// This class manages the nature sounds audio player.

final class NatureAudioManager: ObservableObject {
    static let shared = NatureAudioManager()
    @Published var isMuted: Bool = false
    private var audioPlayer: AVAudioPlayer?
    
    func startPlaying() {
        // Only start playing if not muted.
        guard audioPlayer == nil else { return }
        if let url = Bundle.main.url(forResource: "nature_sounds", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 0.3
                audioPlayer?.prepareToPlay()
                if !isMuted {
                    audioPlayer?.play()
                }
            } catch {
                print("Failed to play nature sounds: \(error.localizedDescription)")
            }
        } else {
            print("Nature sound asset not found.")
        }
    }
    
    // Toggle mute state and pause/play audio player.
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
    }
}
