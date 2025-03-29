//
//  ContentView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Foundation

// MARK: - MainContentView
// This view is the main content view that contains the ARViewContainer, overlays, and floating buttons.
// - It also contains the toast notification and the instruction overlay. The tree controls overlay is shown only after a tree has been planted.
// - The impact stats, leaderboard, and badges floating buttons are placed at the top right corner.

struct MainContentView: View {
    @StateObject var treeVM = TreeViewModel()
    @EnvironmentObject var economy: VirtualEconomyManager
    @State private var showStatsSheet: Bool = false
    @State private var showLeaderboardSheet: Bool = false
    @State private var showBadgesSheet: Bool = false
    
    // Add an observed instance of the nature audio manager.
    @StateObject private var natureAudio = NatureAudioManager.shared
    
    var body: some View {
        ZStack {
            ARViewContainer(treeVM: treeVM)
                .ignoresSafeArea()
                .accessibilityHidden(true) // Hide AR view from VoiceOver
            
            // Toast Notification placed lower with easeIn transition.
            VStack {
                if treeVM.showToast {
                    ToastView(message: treeVM.toastMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 100)
                        .padding(.horizontal)
                        .accessibilityLabel(treeVM.toastMessage)
                        .accessibilityHint("Notification")
                }
                Spacer()
            }
            
            // Top‐left overlay: Current Tree indicator and Carbon Credits.
            VStack {
                HStack {
                    VStack {
                        CurrentTreeIndicator(treeVM: treeVM)
                        CarbonCreditsBox(treeVM: treeVM, economy: economy)
                    }
                    Spacer()
                }
                Spacer()
            }
            
            // Instruction overlay.
            // Show different instructions based on whether a tree has been planted or not.
            if treeVM.trees.isEmpty {
                VStack {
                    Spacer()
                    Text("Tap on a horizontal surface to plant a tree")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .accessibilityLabel("Plant a Tree")
                        .accessibilityHint("Tap on a detected horizontal surface to plant a virtual tree")
                }
            } else {
                VStack {
                    Text("Double tap a planted tree to select it")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .accessibilityLabel("Select a Tree")
                        .accessibilityHint("Double tap on a planted tree to select and interact with it")
                    Spacer()
                }
            }
            
            // Tree controls overlay (only shown after a tree has been planted).
            VStack {
                Spacer()
                TreeOverlayView(treeVM: treeVM)
                    .padding(.bottom, 40)
            }
            
            // Impact Stats, Leaderboard , Your Impact Stats & Badges floating buttons.
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Button {
                            showLeaderboardSheet.toggle()
                        } label: {
                            Image(systemName: "gamecontroller.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Leaderboard")
                        .accessibilityHint("Tap to view Game Center leaderboards")
                        
                        Button {
                            showStatsSheet.toggle()
                        } label: {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Your Impact Stats")
                        .accessibilityHint("Tap to view your impact statistics")
                        
                        Button {
                            showBadgesSheet.toggle()
                        } label: {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Badges")
                        .accessibilityHint("Tap to view your earned badges")
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Mute Button Overlay (placed at the bottom left)
            VStack {
                Spacer()
                HStack {
                    Button {
                        natureAudio.toggleMute()
                    } label: {
                        Image(systemName: natureAudio.isMuted ?
                              "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityLabel(natureAudio.isMuted ? "Unmute Nature Sounds" : "Mute Nature Sounds")
                    .accessibilityHint("Tap to \(natureAudio.isMuted ? "unmute" : "mute") the background nature audio")
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        // Present the impact stats, leaderboard, and badges sheets.
        .sheet(isPresented: $showStatsSheet) {
            ImpactStatsSheetView(treeVM: treeVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLeaderboardSheet) {
            LeaderboardSelectionView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showBadgesSheet) {
            BadgeSheetView(treeVM: treeVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - ContentView (Root)
// The root view of the app that contains the MainContentView and the splash sheets.

struct ContentView: View {
    @State private var showSplashSheet: Bool = true
    @State private var showTreeSelection: Bool = false
    @StateObject var treeVM = TreeViewModel()
    @StateObject var economy = VirtualEconomyManager()
    
    // Create an instance of your tip.
    let selectingTreeTip = SelectingTreeTip()
    
    var body: some View {
        ZStack {
            MainContentView(treeVM: treeVM)
                .environmentObject(economy)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showTreeSelection = true
                        // When tapped, invalidate the tip.
                        selectingTreeTip.invalidate(reason: .actionPerformed)
                    } label: {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.title)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50))
                    }
                    // Add the popover tip modifier
                    .popoverTip(selectingTreeTip)
                    .accessibilityLabel("Tree Selection")
                    .accessibilityHint("Tap to select a different tree")
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showSplashSheet) {
            SplashSheetView(isPresented: $showSplashSheet)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .onDisappear {
                    // Set the tip’s onboarding parameter so it will appear
                    // once the splash screen is dismissed.
                    SelectingTreeTip.onboardingDone = true
                    CarbonStoreTip.onboardingDone = true
                }
        }
        .sheet(isPresented: $showTreeSelection) {
            TreeSelectionView(isPresented: $showTreeSelection, treeVM: treeVM, economy: economy)
        }
    }
}
