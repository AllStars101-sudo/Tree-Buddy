//
//  OnboardingPageView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - OnboardingPageView
// A reusable view for additional onboarding pages (pages 1–3). It displays a title,
// subtitle (now in bold), description, and an SF Symbol icon (tinted green).

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let screenWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer().frame(height: 30)
            
            // Title
            HStack {
                Spacer()
                Text(title)
                    .font(.largeTitle.weight(.heavy))
                    .padding()
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            
            // Icon (explicitly tinted green)
            HStack {
                Spacer()
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.green)
                    .padding()
                    .accessibilityLabel(title)
                Spacer()
            }
            
            // Subtitle & Description
            VStack(alignment: .leading, spacing: 10) {
                Text(subtitle)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
