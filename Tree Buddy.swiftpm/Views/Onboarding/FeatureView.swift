//
//  FeatureView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - FeatureView
// A reusable view for showing an SF symbol and description in the Welcome page.

struct FeatureView: View {
    let symbolName: String
    let symbolColor: Color
    let description: String
    let screenWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: symbolName)
                .font(.title.weight(.medium))
                .frame(width: 40, height: 40)
                .foregroundColor(symbolColor)
                .accessibilityHidden(true)
            Text(description)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal)
        .frame(maxWidth: screenWidth * 0.9, alignment: .leading)
        .accessibilityLabel(description)
    }
}
