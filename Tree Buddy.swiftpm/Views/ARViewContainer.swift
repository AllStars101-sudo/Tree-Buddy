//
//  ARViewContainer.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

// MARK: - ARViewContainer
// This view represents the ARView container that displays the AR scene.
// - It sets up the AR configuration with horizontal plane detection and enables 4K video (and HDR if available) on supported devices.
// - It also sets up gesture recognizers for double and single taps to select and plant trees.
// - The Coordinator class manages the AR session and tree entities, and updates the tree entities based on the tree growth progress.
// - It also handles environment decorations such as grass and rocks.
// This is essentially the heart of the app.

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var treeVM: TreeViewModel
    
    // This method creates the ARView and sets up the AR configuration with horizontal plane detection.
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        
        // Set up AR configuration with horizontal plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        // MARK: - Occlusion
        // Enable mesh scene reconstruction to obtain an occlusion mesh (if supported).
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
            config.environmentTexturing = .automatic
        }
        
        // Enable 4K video (and HDR if available) on devices that support it.
        if #available(iOS 16.0, *) {
            if let recommendedFormat = ARWorldTrackingConfiguration.recommendedVideoFormatFor4KResolution {
                config.videoFormat = recommendedFormat
                // Only enable HDR if the selected video format supports it.
                if recommendedFormat.isVideoHDRSupported {
                    config.videoHDRAllowed = true
                }
            }
        }
        
        // Run the AR session with the configuration and set the coordinator as the session delegate.
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        
        // Gesture recognizers
        let doubleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTapGesture.numberOfTapsRequired = 2
        
        let singleTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSingleTap(_:))
        )
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.require(toFail: doubleTapGesture)
        
        // Add gesture recognizers to the ARView
        arView.addGestureRecognizer(doubleTapGesture)
        arView.addGestureRecognizer(singleTapGesture)
        
        // Start the update timer
        context.coordinator.startUpdateTimer(for: arView)
        
        // Start the nature sounds
        NatureAudioManager.shared.startPlaying()
        
        return arView
    }
    
    // This method updates the ARView.
    func updateUIView(_ uiView: ARView, context: Context) { }
    
    // This method creates the Coordinator instance.
    func makeCoordinator() -> Coordinator {
        Coordinator(treeVM: treeVM)
    }
    
    // MARK: - Coordinator
    // This class manages the AR session and tree entities.
    // It also handles environment decorations such as grass and rocks.
    class Coordinator: NSObject, ARSessionDelegate {
        var treeVM: TreeViewModel
        weak var arView: ARView?
        
        // MARK: - Tree Entities & Timers
        
        struct TreeEntityRecord {
            var anchor: AnchorEntity
            var entity: ModelEntity
            var stage: TreeGrowthStage
            var assetName: String
        }
        var treeEntities: [UUID: TreeEntityRecord] = [:]
        var growthTimer: AnyCancellable?
        
        // MARK: - Environment Decorations
        
        var environmentDecorations: [UUID: AnchorEntity] = [:]
        var grassTemplate: ModelEntity?
        var rockTemplate: ModelEntity?
        
        let saplingMinScale: Float = 0.01
        let saplingMaxScale: Float = 0.02
        let mediumMinScale: Float = 0.02
        let mediumMaxScale: Float = 0.04
        let fullScale: Float = 0.05
        
        init(treeVM: TreeViewModel) {
            self.treeVM = treeVM
            super.init()
            preloadDecorationAssets()
        }
        
        func preloadDecorationAssets() {
            // Preload decoration assets asynchronously to improve performance
            Task {
                do {
                    self.grassTemplate = try await ModelEntity(named: "grass.usdz", in: nil)
                    self.rockTemplate  = try await ModelEntity(named: "rocks.usdz", in: nil)
                } catch {
                    print("Error preloading decoration assets: \(error.localizedDescription)")
                }
            }
        }
        
        // This method starts the update timer to update the tree entities.
        func startUpdateTimer(for arView: ARView) {
            growthTimer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self, weak arView] _ in
                    guard let self = self, let arView = arView else { return }
                    self.updateTreeEntities(in: arView)
                }
        }
        
        // This method calculates the target scale for a tree based on its growth progress.
        func getTargetScale(for tree: TreeModel) -> Float {
            let progress = tree.growthProgress
            switch tree.stage {
            case .sapling:
                let t = Float(min(progress / 0.33, 1.0))
                return lerp(from: saplingMinScale, to: saplingMaxScale, t: t)
            case .medium:
                let t = Float(min((progress - 0.33) / 0.33, 1.0))
                return lerp(from: mediumMinScale, to: mediumMaxScale, t: t)
            case .full:
                return fullScale
            }
        }

        // This method handles the double tap gesture to select a tree.
        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let tapLocation = sender.location(in: arView)
            if let tappedEntity = arView.entity(at: tapLocation) {
                for (id, info) in treeEntities {
                    if info.entity == tappedEntity || info.anchor.children.contains(tappedEntity) {
                        treeVM.currentTreeID = id
                        return
                    }
                }
            }
        }
        
        // This method handles the single tap gesture to plant a tree.
        @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
            // Check if a tree is already selected
            guard let arView = sender.view as? ARView else { return }
            let tapLocation = sender.location(in: arView)
            guard let result = arView.raycast(from: tapLocation,
                                              allowing: .existingPlaneGeometry,
                                              alignment: .horizontal).first else { return }
            
            // Check if a tree is already planted at the tap location
            let tapPosition = result.worldTransform.translation
            let minDistance: Float = 0.1
            for (_, info) in treeEntities {
                let treePos = info.anchor.transform.translation
                if simd_distance(tapPosition, treePos) < minDistance { return }
            }
            
            // Plant a tree at the tap location
            let anchor = AnchorEntity(world: result.worldTransform)
            arView.scene.addAnchor(anchor)
            treeVM.addTree()
            // Add the tree entity to the scene
            if let treeModel = treeVM.trees.last {
                treeVM.currentTreeID = treeModel.id
                do {
                    let treeEntity = try ModelEntity.loadModel(named: treeModel.assetName())
                    treeEntity.generateCollisionShapes(recursive: true)
                    treeEntity.scale = SIMD3<Float>(repeating: 0.01)
                    anchor.addChild(treeEntity)
                    treeEntities[treeModel.id] = TreeEntityRecord(
                        anchor: anchor,
                        entity: treeEntity,
                        stage: treeModel.stage,
                        assetName: treeModel.assetName()
                    )
                } catch {
                    print("Error loading tree asset: \(error.localizedDescription)")
                }
            }
        }
        
        // This method updates the tree entities based on the tree growth progress.
        func updateTreeEntities(in arView: ARView) {
            for tree in treeVM.trees {
                guard var record = treeEntities[tree.id] else { continue }
                let targetScale = tree.targetScale()
                // Update the tree entity if the stage or asset name has changed
                if tree.stage != record.stage || tree.assetName() != record.assetName {
                    do {
                        let newEntity = try ModelEntity.loadModel(named: tree.assetName())
                        newEntity.generateCollisionShapes(recursive: true)
                        newEntity.scale = SIMD3<Float>(repeating: targetScale * 0.8)
                        newEntity.move(
                            to: Transform(scale: SIMD3<Float>(repeating: targetScale)),
                            relativeTo: record.anchor,
                            duration: 0.5,
                            timingFunction: .easeInOut
                        )
                        record.entity.removeFromParent()
                        record.anchor.addChild(newEntity)
                        record.entity = newEntity
                        record.stage = tree.stage
                        record.assetName = tree.assetName()
                        treeEntities[tree.id] = record
                    } catch {
                        print("Error updating asset for tree \(tree.id): \(error.localizedDescription)")
                    }
                } else {
                    let currentScale = record.entity.scale.x
                    if abs(currentScale - targetScale) > 0.001 {
                        record.entity.move(
                            to: Transform(scale: SIMD3<Float>(repeating: targetScale)),
                            relativeTo: record.anchor,
                            duration: 0.5,
                            timingFunction: .easeInOut
                        )
                    }
                }
            }
        }
        
        // MARK: - Environment Decorations
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor,
                   planeAnchor.alignment == .horizontal {
                    addEnvironmentDecorations(for: planeAnchor)
                }
            }
        }
        
        // This method adds environment decorations such as grass and rocks on floor surfaces.
        func addEnvironmentDecorations(for planeAnchor: ARPlaneAnchor) {
            // Only add decorations on floor surfaces.
            guard planeAnchor.classification == .floor else {
                return
            }
            
            guard let arView = arView else { return }
            let decorationAnchor = AnchorEntity(anchor: planeAnchor)
            environmentDecorations[planeAnchor.identifier] = decorationAnchor
            
            let currentPlaneExtent = planeAnchor.planeExtent
            let decorationCount = Int.random(in: 5...8)
            
            // Add grass and rocks as decorations
            for _ in 0..<decorationCount {
                let isRock = Bool.random()
                let decorationModel: ModelEntity
                
                // Load the grass or rock model
                if isRock {
                    if let rockTemplate = rockTemplate {
                        decorationModel = rockTemplate.clone(recursive: true)
                    } else {
                        do {
                            decorationModel = try ModelEntity.loadModel(named: "rocks.usdz")
                        } catch {
                            print("Error loading rocks.usdz: \(error.localizedDescription)")
                            continue
                        }
                    }
                } else {
                    if let grassTemplate = grassTemplate {
                        decorationModel = grassTemplate.clone(recursive: true)
                    } else {
                        do {
                            decorationModel = try ModelEntity.loadModel(named: "grass.usdz")
                        } catch {
                            print("Error loading grass.usdz: \(error.localizedDescription)")
                            continue
                        }
                    }
                }
                
                // Generate collision shapes and set the position and scale
                decorationModel.generateCollisionShapes(recursive: false)
                let xOffset = Float.random(in: -currentPlaneExtent.width/2 ... currentPlaneExtent.width/2)
                let zOffset = Float.random(in: -currentPlaneExtent.height/2 ... currentPlaneExtent.height/2)
                decorationModel.position = SIMD3<Float>(xOffset, 0, zOffset)
                
                // Scale the decoration model
                let scale: Float = isRock ? 0.0007 : 0.008
                decorationModel.scale = SIMD3<Float>(repeating: scale)
                
                decorationAnchor.addChild(decorationModel)
            }
            arView.scene.addAnchor(decorationAnchor)
        }
    }
}
