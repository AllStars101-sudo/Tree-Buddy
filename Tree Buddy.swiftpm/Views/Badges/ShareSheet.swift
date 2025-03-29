//
//  ShareSheet.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import UIKit

// MARK: - ShareSheet
// This view displays a share sheet for sharing content.

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems, 
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    // This method is required but we don't need to do anything here.
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: Context) { }
}
