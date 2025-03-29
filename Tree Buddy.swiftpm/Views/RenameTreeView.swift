//
//  RenameTreeView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - RenameTreeView
// This view allows the user to rename their tree.
// It provides a text field to enter a new name, suggestions, and an environmental fact.

struct RenameTreeView: View {
    @Binding var treeName: String
    @Environment(\.dismiss) var dismiss
    
    // Sample suggestions.
    let suggestions: [String] = [
        "Evergreen Wonder",
        "CO₂ Crusher",
        "Oxygen Oasis",
        "Forest Muse",
        "Nature’s Triumph"
    ]
    
    // Environmental fact.
    let fact: String =
    "Did you know? A mature tree can absorb up to 48 lbs of CO₂ a year!"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // TextField for the tree name.
                TextField("Enter tree name", text: $treeName)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .accessibilityLabel("Tree name")
                    .accessibilityHint("Enter a new name for your tree")
                
                // Suggestions rendered as chips.
                HStack {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            treeName = suggestion
                        } label: {
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .accessibilityLabel("Suggestion: \(suggestion)")
                        .accessibilityHint("Double tap to set the tree name to \(suggestion)")
                    }
                }
                .padding(.horizontal, 20)
                
                // Display environmental fact.
                Text(fact)
                    .font(.footnote)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .accessibilityLabel("Fun Fact")
                    .accessibilityHint(fact)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Rename Tree")
            .accessibilityAddTraits(.isHeader)
            .toolbar {
                // Done button to dismiss the view.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Tap to save the new tree name and dismiss this view")
                }
            }
        }
    }
}
