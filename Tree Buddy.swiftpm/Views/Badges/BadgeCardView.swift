//
//  BadgeCardView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - BadgeCardView
// This view displays a badge with its title, description, and an optional share button.
// The share button is enabled only if the badge has been achieved.

struct BadgeCardView: View {
    let badge: Badge
    let achieved: Bool
    let onShare: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: badge.imageName)
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .accessibilityHidden(true)
                VStack(alignment: .leading) {
                    Text(badge.title)
                        .font(.headline)
                    Text(badge.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: {
                    onShare()
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(achieved ? .blue : .gray)
                })
                .disabled(!achieved)
                .buttonStyle(.plain)
                .accessibilityLabel("Share badge")
                .accessibilityHint("Double tap to share this badge")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
            .overlay(
                Group {
                    if !achieved {
                        // Use a background based on the system background color, with reduced opacity.
                        // This color adapts to both light and dark mode.
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.systemBackground).opacity(0.7))
                            .overlay(
                                Image(systemName: "lock.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                }
            )
        }
    }
}
