//
//  Extensions.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import simd

// MARK: - Extensions
// This file contains extensions for various types used in the app.

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
    
    var eulerAngles: SIMD3<Float> {
        // Converts rotation matrix to Euler angles (using YXZ order).
        let sy = sqrt(self.columns.0.x * self.columns.0.x +
                      self.columns.1.x * self.columns.1.x)
        // Check for singularity.
        let singular = sy < 1e-6
        var x: Float, y: Float, z: Float
        // Singular case: YZX order.
        if !singular {
            x = atan2(self.columns.2.y, self.columns.2.z)
            y = atan2(-self.columns.2.x, sy)
            z = atan2(self.columns.1.x, self.columns.0.x)
        // Non-singular case: YXZ order.
        } else {
            x = atan2(-self.columns.1.z, self.columns.1.y)
            y = atan2(-self.columns.2.x, sy)
            z = 0
        }
        // Return Euler angles.
        return SIMD3<Float>(x, y, z)
    }
}

// Linear interpolation helper.
func lerp(from a: Float, to b: Float, t: Float) -> Float {
    a + (b - a) * t
}
