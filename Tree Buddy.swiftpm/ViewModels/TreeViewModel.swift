//
//  TreeViewModel.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Foundation
import Combine

// MARK: - TreeViewModel
// This view model manages the tree data and growth logic.
// It also handles the toast messages and badge achievements.

class TreeViewModel: ObservableObject {
    @Published var trees: [TreeModel] = []
    @Published var currentTreeID: UUID?
    
    // Tree asset selection.
    @Published var selectedTreeAsset: TreeAsset = .maple // default selection
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    // Virtual economy property: credits earned via badges.
    @Published var carbonCredits: Int = 0
    
    // Badge-related properties.
    @Published var badgeToast: String? = nil
    @Published var earnedBadges: Set<String> = []
    
    // CO2 offset per full-grown tree.
    static let fullTreeCO2Offset: Double = 50.0
    
    // Computed property to calculate total CO2 reduction.
    var totalCO2Reduction: Double {
        trees.reduce(0.0) { $0 + $1.growthProgress * TreeViewModel.fullTreeCO2Offset }
    }
    
    // Impact data points for stats tracking.
    @Published var co2Data: [ImpactDataPoint] = []
    @Published var forestData: [ImpactDataPoint] = []
    @Published var waterData: [ImpactDataPoint] = []
    
    // Demo durations.
    // For trees under acceleration use 2 minutes drying threshold,
    // otherwise use 2 days (172800 seconds)
    let normalDryThreshold: TimeInterval = 172800
    let acceleratedDryThreshold: TimeInterval = 120
    
    // Growth duration for trees.
    var totalGrowthDuration: TimeInterval = 600   // 10-days demo value.
    let defaultGrowthDuration: TimeInterval = 600
    
    // Timer and stats timer.
    private var saplingCounter: Int = 0
    private var timer: AnyCancellable?
    private var statsTimer: AnyCancellable?
    
    init() {
        // Start the tree growth timer.
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.updateTrees(currentDate: now)
            }
        statsTimer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self = self else { return }
                let co2Value = self.trees.reduce(0.0) {
                    $0 + $1.growthProgress * TreeViewModel.fullTreeCO2Offset
                }
                self.co2Data.append(ImpactDataPoint(date: now, value: co2Value))
                self.forestData.append(ImpactDataPoint(date: now,
                                                       value: Double(self.trees.count)))
                let waterTotal = self.trees.reduce(0) { $0 + $1.waterCountToday }
                self.waterData.append(ImpactDataPoint(date: now, value: Double(waterTotal)))
                GameCenterManager.shared.reportCO2Offset(co2Offset: co2Value)
                self.checkBadgeAchievements()
            }
    }
    
    // MARK: - Tree Management

    // Add a new tree to the forest.
    func addTree() {
        saplingCounter += 1
        var tree = TreeModel()
        tree.plantedDate = Date()
        tree.lastWatered = Date()
        tree.lastWaterDate = Date()
        tree.waterCountToday = 0
        tree.asset = selectedTreeAsset
        tree.name = "\(selectedTreeAsset.rawValue.capitalized) \(saplingCounter)"
        trees.append(tree)
        currentTreeID = tree.id

        // Play tree planted sound effect.
        SoundEffectsManager.shared.play(.treePlanted)
        
        toastMessage = "Thank you for planting a new tree 🌱! Check Your Impact to view your CO₂ stats."
        showToast = true
        GameCenterManager.shared.reportTreePlanted(count: trees.count)
        checkBadgeAchievements()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.easeIn(duration: 0.5)) { self.showToast = false }
        }
    }
    
    // Update tree growth and health status.
    func updateTrees(currentDate: Date) {
        for i in trees.indices {
            if !Calendar.current.isDate(trees[i].lastWaterDate, inSameDayAs: currentDate) {
                trees[i].waterCountToday = 0
                trees[i].lastWaterDate = currentDate
            }
            // Use different thresholds based on acceleration.
            let threshold = trees[i].accelerateStartTime != nil ?
            acceleratedDryThreshold : normalDryThreshold
            
            // Check if the tree should become dry and play sound only once.
            if trees[i].health != .dry {
                let shouldBeDry = trees[i].isDry(currentDate: currentDate, dryThreshold: threshold)
                if shouldBeDry {
                    trees[i].health = .dry
                    if !trees[i].hasPlayedDrySound {
                        SoundEffectsManager.shared.play(.treeDry)
                        trees[i].hasPlayedDrySound = true
                    }
                } else {
                    trees[i].health = .healthy
                    trees[i].hasPlayedDrySound = false
                }
            }
            
            // Do not update growth if tree is dry.
            if trees[i].health == .dry {
                continue
            }
            
            if let accelStart = trees[i].accelerateStartTime {
                let elapsedAccel = currentDate.timeIntervalSince(accelStart)
                let acceleratedProgress = trees[i].accelerationBaseProgress +
                ((1 - trees[i].accelerationBaseProgress) * (elapsedAccel / 10.0))
                trees[i].growthProgress = min(acceleratedProgress, 1.0)
            } else {
                trees[i].growthProgress = min(currentDate.timeIntervalSince(trees[i].plantedDate) / totalGrowthDuration, 1.0)
            }
            
            let progress = trees[i].growthProgress
            let desiredStage: TreeGrowthStage = progress < 0.33 ? .sapling : (progress < 0.66 ? .medium : .full)
            if desiredStage != trees[i].stage {
                trees[i].stage = desiredStage
                // Rename tree using asset prefixes.
                let defaultPrefixes = [trees[i].asset.saplingAssetName, trees[i].asset.plantedAssetName]
                for prefix in defaultPrefixes {
                    if trees[i].name.lowercased().hasPrefix(prefix.replacingOccurrences(of: ".usdz", with: "")) {
                        let number = trees[i].name.drop { $0.isLetter }
                        switch desiredStage {
                        case .sapling:
                            trees[i].name = "\(trees[i].asset.saplingAssetName.replacingOccurrences(of: ".usdz", with: ""))\(number)"
                        case .medium:
                            trees[i].name = "\(trees[i].asset.plantedAssetName.replacingOccurrences(of: ".usdz", with: ""))\(number)"
                        case .full:
                            trees[i].name = "\(trees[i].asset.plantedAssetName.replacingOccurrences(of: ".usdz", with: ""))\(number)"
                        }
                        break
                    }
                }
            }
            // When a tree finishes growing, record its full-grown date.
            if trees[i].growthProgress >= 1.0 && trees[i].fullGrownDate == nil {
                trees[i].fullGrownDate = currentDate
            }
        }
        objectWillChange.send()
    }
    
    // MARK: - Tree Actions

    // Water the tree and update its last watered date.
    func waterTree(id: UUID) {
        if let index = trees.firstIndex(where: { $0.id == id }) {
            let now = Date()
            if Calendar.current.isDate(trees[index].lastWaterDate, inSameDayAs: now) {
                if trees[index].waterCountToday < 5 {
                    trees[index].waterCountToday += 1
                }
            } else {
                trees[index].waterCountToday = 1
                trees[index].lastWaterDate = now
            }
            trees[index].lastWatered = now
            
            // Play water splash sound effect.
            SoundEffectsManager.shared.play(.treeWatered)
        }
    }
    
    // Accelerate the tree's growth.
    func accelerateCurrentTree() {
        guard let id = currentTreeID,
              let index = trees.firstIndex(where: { $0.id == id }),
              trees[index].accelerateStartTime == nil,
              trees[index].health != .dry  // do nothing if tree is already dry
        else { return }
        let now = Date()
        let currentProgress = min(now.timeIntervalSince(trees[index].plantedDate) / totalGrowthDuration, 1.0)
        trees[index].accelerateStartTime = now
        trees[index].accelerationBaseProgress = currentProgress
    }
    
    // Apply a growth booster to the tree.
    func applyGrowthBooster(to tree: TreeModel) {
        guard tree.health != .dry else { return }
        totalGrowthDuration = defaultGrowthDuration / 2
    }
    
    // MARK: - Tree Selection

    // Select a tree from the forest.
    func renameCurrentTree(to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trees.map({ $0.name }).contains(trimmed) else { return }
        if let id = currentTreeID,
           let index = trees.firstIndex(where: { $0.id == id }) {
            trees[index].name = trimmed
        }
    }
    
    // Rename the current tree.
    func currentTree() -> TreeModel? {
        if let id = currentTreeID {
            return trees.first { $0.id == id }
        }
        return trees.first
    }
    
    // MARK: - Badge & Economy Integration
    
    // Calculate credits earned for each badge.
    private func creditsForBadge(title: String) -> Int {
        switch title {
        case "Green Thumb": return 10
        case "Forest Forager": return 20
        case "CO₂ Crusader": return 30
        case "Forest Guardian": return 40
        case "Eco Warrior": return 50
        case "Nature Protector": return 60
        default: return 5
        }
    }
    
    // Check if any new badges have been achieved.
    func checkBadgeAchievements() {
        for badge in Badge.sampleBadges {
            if badge.isAchieved(by: self) && !earnedBadges.contains(badge.title) {
                earnedBadges.insert(badge.title)
                let earn = creditsForBadge(title: badge.title)
                carbonCredits += earn
                
                // Play the badge earned sound effect.
                SoundEffectsManager.shared.play(.badgeEarned)
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.badgeToast =
                    "Congratulations, you've unlocked \"\(badge.title)\" and earned \(earn) credits! Check out the store."
                }
                // Dismiss the toast after 5 seconds.
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if self.badgeToast == "Congratulations, you've unlocked \"\(badge.title)\" and earned \(earn) credits! Check out the store." {
                            self.badgeToast = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ToastView
// This view displays a toast message to the user.

struct ToastView: View { 
    let message: String
    
    var body: some View {
        Text(message)
            .font(.body)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.primary)
            .shadow(radius: 5)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(message)
    }
}
