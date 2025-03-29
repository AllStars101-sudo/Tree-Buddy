//
//  CurrentTreeIndicator.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI

// MARK: - CurrentTreeIndicator
// This view displays the current tree name and provides a button to rename the tree.

struct CurrentTreeIndicator: View {
    @ObservedObject var treeVM: TreeViewModel
    @State private var showRenameSheet = false
    @State private var newTreeName: String = ""
    
    var body: some View {
        if let tree = treeVM.currentTree() {
            HStack(spacing: 8) {
                Image(systemName: "leaf.circle.fill")
                    .font(.title2)
                    .accessibilityHidden(true)
                Text(tree.name)
                    .font(.headline)
                    .accessibilityLabel("Current tree: \(tree.name)")
                Button(action: {
                    newTreeName = tree.name
                    showRenameSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .accessibilityLabel("Rename Tree")
                .accessibilityHint("Double tap to rename your current tree")
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.white)
            .padding(.leading)
            .padding(.top, 12)
            .sheet(isPresented: $showRenameSheet) {
                RenameTreeView(treeName: $newTreeName)
                    .onDisappear {
                        if !newTreeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            treeVM.renameCurrentTree(to: newTreeName)
                        }
                    }
            }
        }
    }
}
