import CoreGraphics
import Metal

/// Private enumeration containing bitmap information constants.
private enum BitmapInfo {
    static let noAlpha: UInt32 = CGImageAlphaInfo.none.rawValue
    static let alphaOnly: UInt32 = CGImageAlphaInfo.alphaOnly.rawValue
    static let alphaLast: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue
    static let alphaFirst: UInt32 = CGImageAlphaInfo.premultipliedFirst.rawValue
    static let bigEndian2Bytes: UInt32 = CGImageByteOrderInfo.order16Big.rawValue
    static let littleEndian2Bytes: UInt32 = CGImageByteOrderInfo.order16Little.rawValue
    static let bigEndian4Bytes: UInt32 = CGImageByteOrderInfo.order32Big.rawValue
    static let littleEndian4Bytes: UInt32 = CGImageByteOrderInfo.order32Little.rawValue
    static let useFloats: UInt32 = CGBitmapInfo.floatComponents.rawValue

    /// Alpha channel only
    static let a = Self.alphaOnly
    /// Red channel only
    static let r = Self.noAlpha
    /// RGBA format with 8 bits per channel, big endian
    static let rgba8888 = Self.alphaLast | Self.bigEndian4Bytes
    /// BGRA format with 8 bits per channel, little endian
    static let bgra8888 = Self.alphaFirst | Self.littleEndian4Bytes

    /// RGB565 pixel format
    static let packed565: UInt32 = {
        if #available(macCatalyst 13.1, *) {
            return CGImagePixelFormatInfo.RGB565.rawValue
        } else {
            return 131_072
        }
    }()

    /// RGB555 pixel format
    static let packed555: UInt32 = {
        if #available(macCatalyst 13.1, *) {
            return CGImagePixelFormatInfo.RGB555.rawValue
        } else {
            return 65536
        }
    }()

    /// RGB101010 pixel format
    static let packed1010102: UInt32 = {
        if #available(macCatalyst 13.1, *) {
            return CGImagePixelFormatInfo.RGB101010.rawValue
        } else {
            return 196_608
        }
    }()

    /// RGBCIF10 pixel format
    static let packed101010: UInt32 = {
        if #available(macCatalyst 13.1, *) {
            return CGImagePixelFormatInfo.RGBCIF10.rawValue
        } else {
            return 262_144
        }
    }()
}

public extension MTLPixelFormat {
    /// Returns the compatible CGBitmapInfo for the MTLPixelFormat.
    ///
    /// This property provides the appropriate CGBitmapInfo for creating CGImages
    /// or CGContexts that are compatible with this MTLPixelFormat.
    ///
    /// - Returns: The compatible CGBitmapInfo as a UInt32, or nil if there's no compatible format.
    var compatibleBitmapInfo: UInt32? {
        switch self {
        case .a8Unorm:
            return BitmapInfo.a
        case .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint, .r8Sint:
            return BitmapInfo.r
        case .r16Unorm, .r16Snorm, .r16Uint, .r16Sint:
            return BitmapInfo.r
        case .r16Float:
            return BitmapInfo.r | BitmapInfo.useFloats | BitmapInfo.littleEndian2Bytes
        case .r32Uint, .r32Sint:
            return BitmapInfo.r
        case .r32Float:
            return BitmapInfo.r | BitmapInfo.useFloats
        case .rgba8Unorm, .rgba8Uint, .rgba8Unorm_srgb:
            return BitmapInfo.rgba8888
        case .bgra8Unorm, .bgra8Unorm_srgb:
            return BitmapInfo.bgra8888
        case .rgba16Unorm, .rgba16Uint:
            return BitmapInfo.alphaLast | BitmapInfo.littleEndian2Bytes
        case .rgba16Float:
            return BitmapInfo.alphaLast | BitmapInfo.useFloats | BitmapInfo.littleEndian2Bytes
        case .rgba32Float:
            return BitmapInfo.alphaLast | BitmapInfo.useFloats | BitmapInfo.littleEndian4Bytes
        case .rgb10a2Unorm, .rgb10a2Uint:
            // should be packed1010102 with big endian, but it seems to be broken
            return nil
        case .bgr10a2Unorm:
            // should be packed1010102, but it's currently unsupported
            return BitmapInfo.noAlpha | BitmapInfo.packed101010 | BitmapInfo.littleEndian4Bytes
        case .bgr10_xr, .bgr10_xr_srgb:
            return BitmapInfo.noAlpha | BitmapInfo.packed101010 | BitmapInfo.littleEndian4Bytes
        default:
            // SNorm can't be rendered by CGContext correctly (it cant be limited to positive-only)
            assertionFailure("Unsupported texture format")
            return nil
        }
    }
}
