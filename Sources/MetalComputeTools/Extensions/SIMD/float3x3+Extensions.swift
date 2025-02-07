import simd

/// Computes the sine and cosine of the given angle
/// - Parameters:
///   - a: The angle
///   - sina: A reference to a variable to store the sine of the angle
///   - cosa: A reference to a variable to store the cosine of the angle
func sincos(_ a: TextureMix.Angle, _ sina: inout Float, _ cosa: inout Float)  {
    __sincospif(a.degrees / 180.0, &sina, &cosa)
}

/// Computes the sine and cosine of the given angle
/// - Parameter a: The angle
/// - Returns: A tuple containing the sine and cosine of the angle
func sincos(_ a: TextureMix.Angle) -> (sin: Float, cos: Float) {
    var s: Float = 0.0
    var c: Float = 0.0
    sincos(a, &s, &c)

    return (sin: s, cos: c)
}

extension float3x3 {

    // MARK: - Identity

    /// Returns the identity matrix
    static let identity = matrix_identity_float3x3

    // MARK: - Translate

    /// Returns a translation matrix
    /// - Parameter value: the translation value
    /// - Returns: a new translation matrix
    static func translate(value: SIMD2<Float32>) -> float3x3 {
        float3x3(
            [1,       0,       0],
            [0,       1,       0],
            [value.x, value.y, 1]
        )
    }

    // MARK: - Rotate

    /// Returns a transformation matrix that rotates around the x and then y axes
    /// - Parameter angle: angle
    /// - Returns: a new rotation matrix
    static func rotate(angle: TextureMix.Angle) -> float3x3 {
        let (sin: sx, cos: cx) = sincos(angle)
        return float3x3(
            [cx, -sx, 0],
            [sx,  cx, 0],
            [0,   0,  1]
        )
    }

    // MARK: - Scale

    /// Returns a scaling matrix
    /// - Parameter value: the scaling value
    /// - Returns: a new scaling matrix
    static func scale(value: SIMD2<Float32>) -> float3x3 {
        float3x3(
            [value.x, 0,       0],
            [0,       value.y, 0],
            [0,       0,       1]
        )
    }

    // MARK: - Shear

    /// Returns a shearing matrix along the x-axis
    /// - Parameter sx: The shearing value along the x-axis
    /// - Returns: A new shearing matrix
    static func shear(x: Float32) -> float3x3 {
        float3x3(
            [1, 0, 0],
            [x, 1, 0],
            [0, 0, 1]
        )
    }

    /// Returns a shearing matrix along the y-axis
    /// - Parameter sy: The shearing value along the y-axis
    /// - Returns: A new shearing matrix
    static func shear(y: Float32) -> float3x3 {
        float3x3(
            [1, y, 0],
            [0, 1, 0],
            [0, 0, 1]
        )
    }

    // MARK: - Matrix Operations

    /// Returns a scaling matrix to fit the original size within the bounding size, maintaining the aspect ratio
    /// - Parameters:
    ///   - originalSize: The original size of the object
    ///   - boundingSize: The bounding size to fit the object into
    /// - Returns: A new scaling matrix
    static func aspectFitScale(
        originalSize: SIMD2<Float32>,
        boundingSize: SIMD2<Float32>
    ) -> float3x3 {
        var newSize = boundingSize
        let mW = newSize.x / originalSize.x
        let mH = newSize.y / originalSize.y

        if mH < mW {
            newSize.x = newSize.y / originalSize.y * originalSize.x
        } else if mW < mH {
            newSize.y = newSize.x / originalSize.x * originalSize.y
        }

        return .scale(value: newSize / originalSize)
    }

    /// Returns a scaling matrix to fill the original size within the bounding size, maintaining the aspect ratio and cropping excess
    /// - Parameters:
    ///   - originalSize: The original size of the object
    ///   - boundingSize: The bounding size to fill the object into
    /// - Returns: A new scaling matrix
    static func aspectFillScale(
        originalSize: SIMD2<Float32>,
        boundingSize: SIMD2<Float32>
    ) -> float3x3 {
        var newSize = boundingSize
        let mW = newSize.x / originalSize.x
        let mH = newSize.y / originalSize.y

        if mH > mW {
            newSize.x = newSize.y / originalSize.y * originalSize.x
        } else if mW > mH {
            newSize.y = newSize.x / originalSize.x * originalSize.y
        }

        return .scale(value: newSize / originalSize)
    }

    /// Returns a scaling matrix to fill the original size exactly within the bounding size, without maintaining the aspect ratio
    /// - Parameters:
    ///   - originalSize: The original size of the object
    ///   - boundingSize: The bounding size to fill the object into
    /// - Returns: A new scaling matrix
    static func fillScale(
        originalSize: SIMD2<Float32>,
        boundingSize: SIMD2<Float32>
    ) -> float3x3 {
        .scale(value: boundingSize / originalSize)
    }

}

