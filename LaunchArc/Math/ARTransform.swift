import Foundation
import simd

public class ARTransform {
    
    /// Converts an Azimuth and Elevation into a SIMD vector natively relative to ARKit's `.gravityAndHeading` alignment.
    ///
    /// In ARKit's `.gravityAndHeading` coordinate system:
    /// - +Y is Up (against gravity)
    /// - -Y is Down
    /// - +Z is South
    /// - -Z is North
    /// - +X is East
    /// - -X is West
    ///
    /// - Parameters:
    ///   - azEl: The calculated Azimuth (0 is North, 90 is East) and Elevation (0 is Horizon, 90 is Zenith).
    ///   - distance: The conceptual distance to place the AR object (in meters).
    /// - Returns: A standard `simd_float4x4` transform.
    public static func simdTransform(azEl: AzEl, distance: Float = 100.0) -> simd_float4x4 {
        // Convert degrees to radians
        let azRad = Float(azEl.azimuth) * .pi / 180.0
        let elRad = Float(azEl.elevation) * .pi / 180.0
        
        // Calculate the vector components
        // Spherical to Cartesian coordinates (adjusted for ARKit axes)
        
        // Horizontal distance (projection onto the XZ plane)
        let r_xz = distance * cos(elRad)
        
        // Y is up (elevation)
        let y = distance * sin(elRad)
        
        // In ARKit:
        // Azimuth 0 (North) -> -Z
        // Azimuth 90 (East) -> +X
        // Azimuth 180 (South) -> +Z
        // Azimuth 270 (West) -> -X
        //
        // Therefore:
        // x = r_xz * sin(azimuthRad)
        // z = r_xz * -cos(azimuthRad) // Negative cosine because 0 degrees points down the negative Z axis
        
        let x = r_xz * sin(azRad)
        let z = r_xz * -cos(azRad)
        
        // Create the translation matrix
        var transform = matrix_identity_float4x4
        transform.columns.3 = simd_float4(x, y, z, 1.0)
        
        return transform
    }
}
