//
//  BadgeShareView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - BadgeShareView
// This view displays a badge with the number of trees planted and CO₂ reduced.

struct BadgeShareView: View {
    let badge: Badge
    let treesPlanted: Int
    let co2Reduction: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 25))
                .shadow(radius: 10)
            
            VStack(spacing: 16) {
                Image(systemName: badge.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                Text(badge.title)
                    .font(.title.bold())
                Text(badge.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                HStack {
                    VStack(spacing: 4) {
                        Text("Trees Planted")
                            .font(.caption)
                        Text("\(treesPlanted)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("CO₂ Reduced")
                            .font(.caption)
                        Text(String(format: "%.1f kg", co2Reduction))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(width: 300, height: 400)
    }
}
