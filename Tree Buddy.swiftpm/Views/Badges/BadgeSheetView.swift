//
//  BadgeSheetView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - BadgeSheetView
// This view displays a list of badges that the user has achieved.
// The user can share the badge by tapping on it.

struct BadgeSheetView: View {
    @ObservedObject var treeVM: TreeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var badges: [Badge] = Badge.sampleBadges
    @State private var showShareSheet: Bool = false
    @State private var shareImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(badges) { badge in
                        // Determine if this badge has been achieved.
                        let achieved = badge.isAchieved(by: treeVM)
                        BadgeCardView(badge: badge, achieved: achieved) {
                            // Only allow share if achieved.
                            if achieved {
                                shareBadge(badge)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Your Badges")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.headline.bold())
                    }
                }
            }
        }
        // Set the badge sheet to .large.
        .sheet(isPresented: $showShareSheet) {
            if let shareImage = shareImage {
                ShareSheet(activityItems: [shareImage])
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // Generates a shareable image for the given badge and shows the share sheet.
    private func shareBadge(_ badge: Badge) {
        let treesCount = treeVM.trees.count
        let co2Reduction = treeVM.totalCO2Reduction
        
        let shareView = BadgeShareView(badge: badge,
                                       treesPlanted: treesCount,
                                       co2Reduction: co2Reduction)
        let renderer = ImageRenderer(content: shareView)
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            shareImage = uiImage
            showShareSheet = true
        }
    }
}
