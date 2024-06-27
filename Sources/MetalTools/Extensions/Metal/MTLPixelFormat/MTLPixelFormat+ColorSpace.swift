import CoreGraphics
import Metal

public extension MTLPixelFormat {
    /// Returns a compatible CGColorSpace for the MTLPixelFormat.
    ///
    /// This property provides an appropriate CGColorSpace that matches the color
    /// representation of the MTLPixelFormat. It's useful when creating CGImages or
    /// CGContexts that need to accurately represent the color data stored in textures
    /// with this pixel format.
    ///
    /// - Returns: A CGColorSpace compatible with this pixel format, or nil if there's no direct match.
    var compatibleColorSpace: CGColorSpace? {
        switch self {
        case .a8Unorm, .r8Unorm, .r8Snorm, .r8Uint, .r8Sint, .r16Unorm, .r16Snorm, .r16Uint, .r16Sint,
             .r16Float, .r32Uint, .r32Sint, .r32Float:
            return CGColorSpace(name: CGColorSpace.linearGray)
        case .rg8Unorm, .rg8Snorm, .rg8Uint, .rg8Sint, .rgba8Unorm, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint:
            return CGColorSpace(name: CGColorSpace.linearSRGB)
        case .rg8Unorm_srgb, .rgba8Unorm_srgb, .bgra8Unorm_srgb:
            return CGColorSpace(name: CGColorSpace.sRGB)
        case .rg16Float, .rg32Float, .rgba16Float, .rgba32Float, .bgr10_xr:
            return CGColorSpace(name: CGColorSpace.extendedLinearSRGB)
        case .bgr10_xr_srgb:
            return CGColorSpace(name: CGColorSpace.extendedSRGB)
        default:
            return nil
        }
    }
}
