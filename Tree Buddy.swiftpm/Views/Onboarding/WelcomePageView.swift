//
//  WelcomePageView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - WelcomePageView
// This view displays the welcome launch screen with a title, app icon, and feature list.

struct WelcomePageView: View {
    @Binding var titleOpacity: Double
    @Binding var titleOffset: CGFloat
    @Binding var featureOpacities: [Double]
    let screenWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer().frame(height: 30)
            
            // Centered Title
            HStack {
                Spacer()
                Text("Welcome to Tree Buddy")
                    .font(.largeTitle.weight(.heavy))
                    .padding()
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    titleOpacity = 1.0
                    titleOffset = 0
                }
            }
            
            // Centered App Icon
            HStack {
                Spacer()
                Image("TreeBuddyIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .padding()
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                    .accessibilityLabel("Tree Buddy Icon")
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        titleOpacity = 1.0
                        titleOffset = 0
                    }
                }
            }
            
            // Feature List
            VStack(alignment: .leading, spacing: 20) {
                FeatureView(
                    symbolName: "leaf.arrow.circlepath",
                    symbolColor: .green,
                    description: "Plant virtual trees with a simple tap",
                    screenWidth: screenWidth
                )
                .opacity(featureOpacities[0])
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            featureOpacities[0] = 1.0
                        }
                    }
                }
                FeatureView(
                    symbolName: "chart.bar.xaxis",
                    symbolColor: .blue,
                    description: "Track your CO₂ reduction, forest growth & water usage",
                    screenWidth: screenWidth
                )
                .opacity(featureOpacities[1])
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            featureOpacities[1] = 1.0
                        }
                    }
                }
                FeatureView(
                    symbolName: "hare.fill",
                    symbolColor: .orange,
                    description: "Earn badges and share your impact",
                    screenWidth: screenWidth
                )
                .opacity(featureOpacities[2])
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            featureOpacities[2] = 1.0
                        }
                    }
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            .accessibilityElement(children: .contain)
            
            Spacer()
        }
    }
}
