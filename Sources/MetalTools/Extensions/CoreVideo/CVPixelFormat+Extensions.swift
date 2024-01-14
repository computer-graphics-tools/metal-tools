import CoreVideo
import Metal

public extension OSType {
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
