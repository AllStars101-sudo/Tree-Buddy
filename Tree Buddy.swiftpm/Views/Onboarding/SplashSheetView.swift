//
//  SplashSheetView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - SplashSheetView
// This view displays the onboarding splash screen with a series of pages.
// It uses a TabView to display the onboarding pages and a global Continue button.
// The first page includes a welcome message and a footer text.
// The second to fourth pages display onboarding content.

struct SplashSheetView: View {
    @Binding var isPresented: Bool
    @State private var currentPage: Int = 0
    
    // Animation states for the Welcome page.
    @State private var titleOpacity = 0.0
    @State private var titleOffset: CGFloat = 20
    @State private var featureOpacities: [Double] = [0.0, 0.0, 0.0]
    @State private var continueButtonOpacity = 0.0
    @State private var footerOpacity: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                TabView(selection: $currentPage) {
                    // Page 0: Welcome
                    WelcomePageView(
                        titleOpacity: $titleOpacity,
                        titleOffset: $titleOffset,
                        featureOpacities: $featureOpacities,
                        screenWidth: geometry.size.width
                    )
                    .tag(0)
                    
                    // Page 1: My Goal
                    OnboardingPageView(
                        title: "My Goal",
                        subtitle: "Inspire Real‑World Change",
                        description: "I believe that planting virtual trees is just the beginning. My vision is that by nurturing a digital forest, users will feel empowered and motivated to plant real trees—making a tangible difference in our environment, one act of green at a time.",
                        imageName: "leaf.arrow.circlepath",
                        screenWidth: geometry.size.width
                    )
                    .tag(1)
                    
                    // Page 2: Getting Started
                    OnboardingPageView(
                        title: "Getting Started",
                        subtitle: "Plant Your First Tree",
                        description: "Simply tap on any horizontal surface to plant a tree. Watch your forest grow with every tap.",
                        imageName: "hand.tap",
                        screenWidth: geometry.size.width
                    )
                    .tag(2)
                    
                    // Page 3: Earn Carbon Credits
                    OnboardingPageView(
                        title: "Earn Carbon Credits",
                        subtitle: "Track & Invest in Your Success",
                        description: "Monitor your CO₂ reduction, earn credits, unlock badges, and share your impact with the world.",
                        imageName: "creditcard.fill",
                        screenWidth: geometry.size.width
                    )
                    .tag(3)
                }
                // Explicit animation modifier to animate tab changes.
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // hides the 4 dots above continue
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Global Continue (or Get Started) Button
                HStack {
                    Spacer()
                    Button(action: {
                        if currentPage < 3 {
                            withAnimation(.easeInOut) { currentPage += 1 }
                        } else {
                            withAnimation(.easeInOut) { isPresented = false }
                        }
                    }) {
                        Text(currentPage < 3 ? "Continue" : "Get Started")
                            .font(.headline.weight(.bold))
                            .padding(.vertical, 16)
                            .frame(maxWidth: geometry.size.width * 0.85)
                            .foregroundColor(.white)
                            .background(
                                Color.green,
                                in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                            )
                    }
                    .accessibilityLabel(currentPage < 3 ? "Continue" : "Get Started")
                    .accessibilityHint(currentPage < 3 ? "Proceed to the next step" : "Finish onboarding")
                    Spacer()
                }
                .padding(.bottom, 10)
                // Animate the Continue button's opacity on page 0; on other pages, it's fully visible.
                .opacity(currentPage == 0 ? continueButtonOpacity : 1.0)
                .onAppear {
                    if currentPage == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                continueButtonOpacity = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    footerOpacity = 1.0
                                }
                            }
                        }
                    }
                }
                .onChange(of: currentPage) { oldValue, newValue in
                    if newValue != 0 {
                        continueButtonOpacity = 1.0
                        footerOpacity = 0.0
                    } else {
                        continueButtonOpacity = 0.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                continueButtonOpacity = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    footerOpacity = 1.0
                                }
                            }
                        }
                    }
                }
                
                // Footer Text appears only on page 0 and is animated in.
                if currentPage == 0 {
                    HStack {
                        Spacer()
                        Text("Made by Chris Pagolu with ❤️")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .opacity(footerOpacity)
                    .padding(.bottom, 30)
                } else {
                    Spacer().frame(height: 30)
                }
            }
            .padding(.horizontal)
        }
    }
}
