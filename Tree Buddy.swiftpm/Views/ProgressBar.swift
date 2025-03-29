//
//  ProgressBar.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - ProgressBar
// This view displays a progress bar with a given progress value and tint color.
// Used to show progress of watering and accelerating a tree's growth.

struct ProgressBar: View {
    var progress: CGFloat  // value between 0 and 1
    var tint: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.gray.opacity(0.2))
            Capsule()
                .fill(tint)
                .frame(width: 150 * progress, height: 8)
                .animation(.easeInOut(duration: 0.2), value: progress)
        }
        .frame(width: 150, height: 8)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}
