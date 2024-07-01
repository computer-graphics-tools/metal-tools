import CoreVideo
import Metal

public extension OSType {
    /// Provides the compatible Metal pixel format for a given Core Video pixel format.
    ///
    /// This property maps Core Video pixel format types to their corresponding Metal pixel formats.
    /// If there is no direct correspondence, it returns nil.
    ///
    /// - Returns: The corresponding MTLPixelFormat, or nil if no compatible format exists.
    var compatibleMTLPixelFormat: MTLPixelFormat? {
        switch self {
        case kCVPixelFormatType_OneComponent8: return .r8Unorm
        case kCVPixelFormatType_OneComponent16Half: return .r16Float
        case kCVPixelFormatType_OneComponent32Float: return .r32Float

        case kCVPixelFormatType_TwoComponent8: return .rg8Unorm
        case kCVPixelFormatType_TwoComponent16Half: return .rg16Float
        case kCVPixelFormatType_TwoComponent32Float: return .rg32Float

        case kCVPixelFormatType_32BGRA: return .bgra8Unorm
        case kCVPixelFormatType_32RGBA: return .rgba8Unorm
        case kCVPixelFormatType_64RGBAHalf: return .rgba16Float
        case kCVPixelFormatType_128RGBAFloat: return .rgba32Float

        case kCVPixelFormatType_DepthFloat32: return .depth32Float
        default: return nil
        }
    }
}
