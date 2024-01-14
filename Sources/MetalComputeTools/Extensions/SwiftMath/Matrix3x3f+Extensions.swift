import SwiftMath

extension Matrix3x3f {
    static func aspectFitScale(originalSize: SIMD2<Float>,
                               boundingSize: SIMD2<Float>) -> Matrix3x3f {
        var newSize = boundingSize
        let mW = newSize.x / originalSize.x
        let mH = newSize.y / originalSize.y

        if( mH < mW ) {
            newSize.x = newSize.y / originalSize.y * originalSize.x
        }
        else if( mW < mH ) {
            newSize.y = newSize.x / originalSize.x * originalSize.y
        }

        return .scale(sx: newSize.x / originalSize.x,
                      sy: newSize.y / originalSize.y)
    }

    static func aspectFillScale(originalSize: SIMD2<Float>,
                                boundingSize: SIMD2<Float>) -> Matrix3x3f {
        var newSize = boundingSize
        let mW = newSize.x / originalSize.x
        let mH = newSize.y / originalSize.y

        if( mH > mW ) {
            newSize.x = newSize.y / originalSize.y * originalSize.x
        }
        else if( mW > mH ) {
            newSize.y = newSize.x / originalSize.x * originalSize.y
        }

        return .scale(sx: newSize.x / originalSize.x,
                      sy: newSize.y / originalSize.y)
    }

    static func fillScale(originalSize: SIMD2<Float>,
                          boundingSize: SIMD2<Float>) -> Matrix3x3f {
        return .scale(sx: boundingSize.x / originalSize.x,
                      sy: boundingSize.y / originalSize.y)
    }

    static func shear(sx: Float) -> Matrix3x3f {
        var matrix = Matrix3x3f.identity
        matrix[1][0] = sx
        return matrix
    }

    static func shear(sy: Float) -> Matrix3x3f {
        var matrix = Matrix3x3f.identity
        matrix[0][1] = sy
        return matrix
    }
}
