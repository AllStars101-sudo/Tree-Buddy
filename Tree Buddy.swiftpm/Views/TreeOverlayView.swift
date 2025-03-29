//
//  TreeOverlayView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - TreeOverlayView
// This view displays the water and accelerate buttons, progress bars, and alerts for watering and accelerating.

struct TreeOverlayView: View {
    @ObservedObject var treeVM: TreeViewModel
    
    // States for watering simulation.
    @State private var wateringProgress: CGFloat = 0.0
    @State private var isWatering: Bool = false
    @State private var wateringTimer: Timer?
    
    // Accelerate states.
    @State private var isAccelerating: Bool = false
    @State private var accelerateProgress: CGFloat = 0.0
    @State private var accelerateTimer: Timer?
    
    // Water reminder timer and alert.
    @State private var waterReminderTimer: Timer?
    @State private var showWaterReminderAlert: Bool = false
    
    // New state to hold the watering reminder message including tree names.
    @State private var reminderMessage: String = ""
    
    // Alerts for watering initial warning and accelerate.
    @State private var showWaterWarning: Bool = false
    @State private var didWarnWatering: Bool = false
    @State private var showAccelerateWarning: Bool = false
    
    var body: some View {
        if treeVM.trees.isEmpty {
            EmptyView()
        } else {
            VStack(spacing: 8) {
                // Animated badge toast.
                if let badgeToast = treeVM.badgeToast {
                    ToastView(message: badgeToast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.bottom, 8)
                }
                
                HStack(spacing: 20) {
                    // Water Button.
                    Button(action: {
                        // If no warning has been shown, show the warning before watering.
                        if !didWarnWatering && treeVM.currentTree()?.waterCountToday == 0 {
                            showWaterWarning = true
                            return
                        }
                        startWatering()
                    }) {
                        Label("Water", systemImage: "drop.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.8), Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: Capsule()
                            )
                            .shadow(color: Color.blue.opacity(0.6), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Water your tree")
                    .accessibilityHint("Tap to water your tree to keep it healthy")
                    
                    // Accelerate Button.
                    Button(action: {
                        if !isAccelerating {
                            showAccelerateWarning = true
                        }
                    }) {
                        Label("Accelerate", systemImage: "bolt.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.8), Color.green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: Capsule()
                            )
                            .shadow(color: Color.green.opacity(0.6), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Accelerate growth")
                    .accessibilityHint("Tap to accelerate your tree’s growth, but be aware of increased watering needs")
                    .alert("Accelerate Growth", isPresented: $showAccelerateWarning) {
                        Button("Continue") {
                            // Play accelerate growth sound effect.
                            SoundEffectsManager.shared.play(.accelerateGrowth)
                            startAccelerating()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Accelerating growth will fast‑forward the tree’s development to just a few seconds. Please note that this demo mode requires extra watering, while under normal conditions, trees take about 10 days to reach full maturity.")
                    }
                }
                .padding(.horizontal)
                
                // Progress bars.
                if isWatering || isAccelerating {
                    HStack(spacing: 20) {
                        if isWatering {
                            ProgressBar(progress: wateringProgress, tint: .blue)
                        }
                        if isAccelerating {
                            ProgressBar(progress: accelerateProgress, tint: .green)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            // Watering reminder alert.
            .alert("Watering Reminder", isPresented: $showWaterReminderAlert) {
                Button("Water Now") {
                    waterOverdueTrees()
                    showWaterReminderAlert = false
                }
                Button("Later", role: .cancel) {
                    showWaterReminderAlert = false
                }
            } message: {
                Text(reminderMessage)
            }
            // Schedule the water reminder when the view appears or when the current tree selection changes.
            .onAppear {
                scheduleWaterReminder()
            }
            .onChange(of: treeVM.currentTreeID) { _, _ in
                waterReminderTimer?.invalidate()
                scheduleWaterReminder()
            }
            .onDisappear {
                waterReminderTimer?.invalidate()
            }
            // Watering warning alert remains unchanged.
            .alert("Important Reminder", isPresented: $showWaterWarning) {
                Button("Continue") {
                    didWarnWatering = true
                    startWatering()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if let tree = treeVM.currentTree() {
                    if tree.accelerateStartTime != nil {
                        Text("Accelerated plants require watering every 2 minutes to survive. Otherwise, they can survive for up to 5 days.")
                    } else {
                        Text("Plants require watering every 5 days to survive. If accelerated, they will require watering every 2 minutes.")
                    }
                } else {
                    Text("")
                }
            }
        }
    }
    
    // MARK: - Water Reminder Helpers
    
    // Checks all trees and returns a tuple containing the names of overdue trees (if any)
    // and the shortest time (in seconds) before the next tree becomes overdue.
    private func checkWateringStatus() -> (overdueNames: [String], nextInterval: TimeInterval?) {
        let now = Date()
        var nextInterval: TimeInterval?
        var overdueNames: [String] = []
        
        for tree in treeVM.trees {
            // For accelerated trees, use 60 seconds; otherwise, use 432,000 seconds (5 days) for demo.
            let threshold: TimeInterval = (tree.accelerateStartTime != nil) ? 60 : 432000
            let timeSinceWatered = now.timeIntervalSince(tree.lastWatered)
            if timeSinceWatered >= threshold {
                overdueNames.append(tree.name)
            }
            let timeRemaining = threshold - timeSinceWatered
            if timeRemaining <= 0 {
                nextInterval = 0
                break
            } else {
                nextInterval = nextInterval.map { min($0, timeRemaining) } ?? timeRemaining
            }
        }
        
        return (overdueNames, nextInterval)
    }
    
    // Waters all trees that are overdue.
    private func waterOverdueTrees() {
        let now = Date()
        for tree in treeVM.trees {
            let threshold: TimeInterval = (tree.accelerateStartTime != nil) ? 60 : 432000
            if now.timeIntervalSince(tree.lastWatered) >= threshold {
                treeVM.waterTree(id: tree.id)
            }
        }
    }
    
    // Updates the reminder alert message based on the names of overdue trees.
    private func updateReminderMessage(with overdueNames: [String]) {
        if overdueNames.count == 1, let name = overdueNames.first {
            reminderMessage =
            "Your tree \"\(name)\" requires watering to remain healthy. Please water it soon. Note: Clicking 'Water Now' will water all trees in your garden."
        } else if overdueNames.count > 1 {
            let names = overdueNames.joined(separator: ", ")
            reminderMessage =
            "Your trees \(names) require watering to remain healthy. Please water them soon. Note: Clicking 'Water Now' will water all trees in your garden."
        }
    }
    
    // Schedules (or reschedules) the watering reminder timer to fire every minute
    // as long as there is at least one tree that is overdue.
    private func scheduleWaterReminder() {
        // Cancel any previous timer.
        waterReminderTimer?.invalidate()
        
        // Immediately check the watering status.
        let status = checkWateringStatus()
        
        // If at least one tree is overdue, show the alert immediately.
        if !status.overdueNames.isEmpty {
            updateReminderMessage(with: status.overdueNames)
            SoundEffectsManager.shared.play(.waterReminder)
            showWaterReminderAlert = true
        }
        
        // Start a repeating timer that fires every minute to re‑check watering conditions.
        waterReminderTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            let currentStatus = checkWateringStatus()
            if !currentStatus.overdueNames.isEmpty {
                updateReminderMessage(with: currentStatus.overdueNames)
                SoundEffectsManager.shared.play(.waterReminder)
                showWaterReminderAlert = true
            }
        }
    }
    
    // MARK: - Other Tree Actions
    
    // Animates watering progress and calls waterTree on completion.
    private func startWatering() {
        isWatering = true
        wateringProgress = 0.0
        wateringTimer?.invalidate()
        waterReminderTimer?.invalidate() // cancel pending reminders while watering
        
        wateringTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            wateringProgress += 0.05
            if wateringProgress >= 1.0 {
                // Water all overdue trees when watering completes.
                waterOverdueTrees()
                timer.invalidate()
                isWatering = false
                scheduleWaterReminder()
            }
        }
    }
    
    // Animates the accelerate progress and triggers the growth acceleration.
    private func startAccelerating() {
        isAccelerating = true
        accelerateProgress = 0.0
        treeVM.accelerateCurrentTree()
        accelerateTimer?.invalidate()
        accelerateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if let tree = treeVM.currentTree() {
                let effectiveDuration = 10.0 * (1 - tree.accelerationBaseProgress)
                let elapsed = Date().timeIntervalSince(tree.accelerateStartTime ?? Date())
                let progressCalc = (elapsed / effectiveDuration) * (1 - tree.accelerationBaseProgress) + tree.accelerationBaseProgress
                let progress = CGFloat(min(progressCalc, 1.0))
                accelerateProgress = progress
                if progress >= 1.0 {
                    timer.invalidate()
                    isAccelerating = false
                    accelerateProgress = 0.0
                    scheduleWaterReminder()
                }
            } else {
                timer.invalidate()
                isAccelerating = false
            }
        }
    }
}
