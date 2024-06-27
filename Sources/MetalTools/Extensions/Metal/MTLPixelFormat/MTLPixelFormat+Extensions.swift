import Metal

public extension MTLPixelFormat {
    /// Represents the scalar type of the pixel format components.
    enum ScalarType: String {
        case float, half, ushort, short, uint, int
    }
    
    /// The number of bits per component in the pixel format.
    var bitsPerComponent: Int? {
        guard !self.isCompressed,
              let bitsPerPixel = self.bitsPerPixel,
              let componentCount = self.componentCount
        else { return nil }
        return bitsPerPixel / componentCount
    }

    /// The total number of bits per pixel in the format.
    var bitsPerPixel: Int? {
        if self.isOrdinary8Bit {
            return 8
        } else if self.isOrdinary16Bit || self.isPacked16Bit {
            return 16
        } else if self.isOrdinary32Bit || self.isPacked32Bit  {
            return 32
        } else if self.isNormal64Bit  {
            return 64
        } else if self.isNormal128Bit {
            return 128
        }
        return nil
    }
    
    /// The number of color components in the pixel format.
    var componentCount: Int? {
        switch self {
        case .invalid:
            return nil
        case .a8Unorm, .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint,
             .r8Sint, .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float, .r32Uint, .r32Sint, .r32Float,
             .depth16Unorm, .depth32Float, .stencil8:
            return 1
        case .rg8Unorm, .rg8Unorm_srgb, .rg8Snorm, .rg8Uint, .rg8Sint,
             .rg16Unorm, .rg16Snorm, .rg16Uint, .rg16Sint, .rg16Float,
             .rg32Uint, .rg32Sint, .rg32Float, .depth32Float_stencil8, .x32_stencil8:
            return 2
        case .b5g6r5Unorm, .rg11b10Float, .rgb9e5Float, .gbgr422, .bgrg422:
            return 3
        case .a1bgr5Unorm, .abgr4Unorm, .bgr5A1Unorm, .rgba8Unorm, .rgba8Unorm_srgb, .rgba8Snorm,
             .rgba8Uint, .rgba8Sint, .bgra8Unorm, .bgra8Unorm_srgb, .rgb10a2Unorm, .rgb10a2Uint, .bgr10a2Unorm,
             .bgr10_xr, .bgr10_xr_srgb, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint, .rgba16Float,
             .bgra10_xr, .bgra10_xr_srgb, .rgba32Uint, .rgba32Sint, .rgba32Float:
            return 4
        case .bc4_rUnorm, .bc4_rSnorm, .eac_r11Unorm, .eac_r11Snorm:
            return 1 // Compressed formats, typically 1 component
        case .bc5_rgUnorm, .bc5_rgSnorm:
            return 2 // Compressed formats, typically 2 components
        case .bc6H_rgbFloat, .bc6H_rgbuFloat, .pvrtc_rgb_2bpp, .pvrtc_rgb_2bpp_srgb, .pvrtc_rgb_4bpp,
             .pvrtc_rgb_4bpp_srgb, .eac_rg11Unorm, .eac_rg11Snorm, .etc2_rgb8, .etc2_rgb8_srgb:
            return 3 // Compressed formats, typically 3 components
        case .bc1_rgba, .bc1_rgba_srgb, .bc2_rgba, .bc2_rgba_srgb, .bc3_rgba, .bc3_rgba_srgb,
             .etc2_rgb8a1, .etc2_rgb8a1_srgb, .eac_rgba8, .eac_rgba8_srgb, .bc7_rgbaUnorm, .bc7_rgbaUnorm_srgb,
             .pvrtc_rgba_2bpp, .pvrtc_rgba_2bpp_srgb, .pvrtc_rgba_4bpp, .pvrtc_rgba_4bpp_srgb:
            return 4 // Compressed formats, typically 4 components
        default: return nil
        }
    }
    
    /// The number of bytes per pixel in the format.
    var bytesPerPixel: Int? {
        switch self {
        case .a8Unorm, .r8Unorm, .r8Snorm, .r8Uint, .r8Sint, .stencil8, .r8Unorm_srgb:
            return 1
        case .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float, .rg8Unorm, .rg8Snorm, .rg8Uint, 
             .rg8Sint, .depth16Unorm, .rg8Unorm_srgb:
            return 2
        case .r32Uint, .r32Sint, .r32Float, .rg16Unorm, .rg16Snorm, .rg16Uint, .rg16Sint, .rg16Float,
             .rgba8Unorm, .rgba8Unorm_srgb, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .bgra8Unorm_srgb,
             .rgb10a2Unorm, .rgb10a2Uint, .rg11b10Float, .rgb9e5Float, .bgr10a2Unorm, .gbgr422, .bgrg422, .depth32Float,
             .bgr10_xr_srgb, .bgr10_xr, .depth24Unorm_stencil8, .x24_stencil8:
            return 4
        case .rg32Uint, .rg32Sint, .rg32Float, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint, .rgba16Float,
             .depth32Float_stencil8, .x32_stencil8, .bgra10_xr, .bgra10_xr_srgb:
            return 8
        case .rgba32Uint, .rgba32Sint, .rgba32Float, .bc2_rgba, .bc2_rgba_srgb, .bc3_rgba, .bc3_rgba_srgb:
            return 16
        case .b5g6r5Unorm, .a1bgr5Unorm, .abgr4Unorm, .bgr5A1Unorm:
            return 2
        case .bc1_rgba, .bc1_rgba_srgb, .bc4_rUnorm, .bc4_rSnorm, .eac_r11Unorm, .eac_r11Snorm, .etc2_rgb8, 
             .etc2_rgb8_srgb, .etc2_rgb8a1, .etc2_rgb8a1_srgb:
            return 8 // Compressed formats, bytes per pixel can vary
        case .bc5_rgUnorm, .bc5_rgSnorm, .bc6H_rgbFloat, .bc6H_rgbuFloat, .bc7_rgbaUnorm, .bc7_rgbaUnorm_srgb,
             .eac_rg11Unorm, .eac_rg11Snorm, .eac_rgba8, .eac_rgba8_srgb, .astc_4x4_srgb, .astc_5x4_srgb,
             .astc_5x5_srgb, .astc_6x5_srgb, .astc_6x6_srgb, .astc_8x5_srgb, .astc_8x6_srgb, .astc_8x8_srgb,
             .astc_10x5_srgb, .astc_10x6_srgb, .astc_10x8_srgb, .astc_10x10_srgb, .astc_12x10_srgb, .astc_12x12_srgb,
             .astc_4x4_ldr, .astc_5x4_ldr, .astc_5x5_ldr, .astc_6x5_ldr, .astc_6x6_ldr, .astc_8x5_ldr, .astc_8x6_ldr,
             .astc_8x8_ldr, .astc_10x5_ldr, .astc_10x6_ldr, .astc_10x8_ldr, .astc_10x10_ldr, .astc_12x10_ldr,
             .astc_12x12_ldr, .astc_4x4_hdr, .astc_5x4_hdr, .astc_5x5_hdr, .astc_6x5_hdr, .astc_6x6_hdr, .astc_8x5_hdr,
             .astc_8x6_hdr, .astc_8x8_hdr, .astc_10x5_hdr, .astc_10x6_hdr, .astc_10x8_hdr, .astc_10x10_hdr,
             .astc_12x10_hdr, .astc_12x12_hdr:
            return 16 // Compressed formats, bytes per pixel can vary
        case .pvrtc_rgb_2bpp, .pvrtc_rgb_2bpp_srgb, .pvrtc_rgb_4bpp, .pvrtc_rgb_4bpp_srgb, .pvrtc_rgba_2bpp,
             .pvrtc_rgba_2bpp_srgb, .pvrtc_rgba_4bpp, .pvrtc_rgba_4bpp_srgb:
            return 2 // Compressed formats, bytes per pixel can vary
        case .invalid:
            return nil
        @unknown default:
            return nil
        }
    }
    
    /// Indicates if the format is an ordinary 8-bit format.
    var isOrdinary8Bit: Bool {
        switch self {
        case .a8Unorm, .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint, .r8Sint:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is an ordinary 16-bit format.
    var isOrdinary16Bit: Bool {
        switch self {
        case .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float,
             .rg8Unorm, .rg8Unorm_srgb, .rg8Snorm, .rg8Uint, .rg8Sint:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a packed 16-bit format.
    var isPacked16Bit: Bool {
        switch self {
        case .b5g6r5Unorm, .a1bgr5Unorm, .abgr4Unorm, .bgr5A1Unorm:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is an ordinary 32-bit format.
    var isOrdinary32Bit: Bool {
        switch self {
        case .r32Uint, .r32Sint, .r32Float,
             .rg16Unorm,  .rg16Snorm, .rg16Uint, .rg16Sint, .rg16Float,
             .rgba8Unorm, .rgba8Unorm_srgb, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .bgra8Unorm_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a packed 32-bit format.
    var isPacked32Bit: Bool {
        switch self {
        case .rgb10a2Unorm, .rgb10a2Uint, .rg11b10Float, .rgb9e5Float,
             .bgr10a2Unorm, .bgr10_xr, .bgr10_xr_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a normal 64-bit format.
    var isNormal64Bit: Bool {
        switch self {
        case .rg32Uint, .rg32Sint, .rg32Float, .rgba16Unorm,
             .rgba16Snorm, .rgba16Uint, .rgba16Sint, .rgba16Float,
             .bgra10_xr, .bgra10_xr_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a normal 128-bit format.
    var isNormal128Bit: Bool {
        switch self {
        case .rgba32Uint, .rgba32Sint, .rgba32Float:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format uses sRGB color space.
    var isSRGB: Bool {
        switch self {
        case .bgra8Unorm_srgb, .bgr10_xr_srgb, .bgra10_xr_srgb,
             .r8Unorm_srgb, .rg8Unorm_srgb,
             .rgba8Unorm_srgb,
             .astc_4x4_srgb, .astc_5x4_srgb, .astc_5x5_srgb, .astc_6x5_srgb,
             .astc_6x6_srgb, .astc_8x5_srgb, .astc_8x6_srgb, .astc_8x8_srgb,
             .pvrtc_rgb_2bpp_srgb, .pvrtc_rgb_4bpp_srgb, .pvrtc_rgba_2bpp_srgb, .pvrtc_rgba_4bpp_srgb,
             .etc2_rgb8a1_srgb, .etc2_rgb8_srgb, .eac_rgba8_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format supports extended range.
    var isExtendedRange: Bool {
        switch self {
        case .bgr10_xr, .bgr10_xr_srgb,
             .bgra10_xr, .bgra10_xr_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a compressed format.
    var isCompressed: Bool {
        return self.isPVRTC
            || self.isEAC
            || self.isETC
            || self.isASTC
            || self.isHDRASTC
            || self.isS3TC
            || self.isRGTC
            || self.isBPTC
    }
    
    /// Indicates if the format is a PVRTC compressed format.
    var isPVRTC: Bool {
        switch self {
        case .pvrtc_rgb_2bpp, .pvrtc_rgb_2bpp_srgb, .pvrtc_rgb_4bpp, .pvrtc_rgb_4bpp_srgb,
             .pvrtc_rgba_2bpp, .pvrtc_rgba_2bpp_srgb, .pvrtc_rgba_4bpp, .pvrtc_rgba_4bpp_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is an ASTC compressed format.
    var isASTC: Bool {
        switch self {
        case .astc_4x4_srgb, .astc_5x4_srgb, .astc_5x5_srgb, .astc_6x5_srgb, .astc_6x6_srgb, .astc_8x5_srgb,
             .astc_8x6_srgb, .astc_8x8_srgb, .astc_10x5_srgb, .astc_10x6_srgb, .astc_10x8_srgb, .astc_10x10_srgb,
             .astc_12x10_srgb, .astc_12x12_srgb, .astc_4x4_ldr, .astc_5x4_ldr, .astc_5x5_ldr, .astc_6x5_ldr,
             .astc_6x6_ldr, .astc_8x5_ldr, .astc_8x6_ldr, .astc_8x8_ldr, .astc_10x5_ldr, .astc_10x6_ldr,
             .astc_10x8_ldr, .astc_10x10_ldr, .astc_12x10_ldr, .astc_12x12_ldr:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a HDR ASTC compressed format.
    var isHDRASTC: Bool {
        switch self {
        case .astc_4x4_hdr, .astc_5x4_hdr, .astc_5x5_hdr, .astc_6x5_hdr, .astc_6x6_hdr, .astc_8x5_hdr,
             .astc_8x6_hdr, .astc_8x8_hdr, .astc_10x5_hdr, .astc_10x6_hdr, .astc_10x8_hdr, .astc_10x10_hdr,
             .astc_12x10_hdr, .astc_12x12_hdr:
            return true
        default: return false
        }
    }

    /// Indicates if the format is an ETC compressed format.
    var isETC: Bool {
        switch self {
        case .etc2_rgb8, .etc2_rgb8_srgb, .etc2_rgb8a1, .etc2_rgb8a1_srgb:
            return true
        default: return false
        }
    }

    /// Indicates if the format is an EAC compressed format.
    var isEAC: Bool {
        switch self {
        case .eac_r11Unorm, .eac_r11Snorm, .eac_rg11Unorm,
             .eac_rg11Snorm, .eac_rgba8, .eac_rgba8_srgb:
            return true
        default: return false
        }
    }

    /// Indicates if the format is an S3TC compressed format.
    var isS3TC: Bool {
        switch self {
        case .bc1_rgba, .bc1_rgba_srgb,
             .bc2_rgba, .bc2_rgba_srgb,
             .bc3_rgba, .bc3_rgba_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is an RGTC compressed format.
    var isRGTC: Bool {
        switch self {
        case .bc4_rUnorm, .bc4_rSnorm,
             .bc5_rgUnorm, .bc5_rgSnorm:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a BPTC compressed format.
    var isBPTC: Bool {
        switch self {
        case .bc6H_rgbFloat, .bc6H_rgbuFloat,
             .bc7_rgbaUnorm, .bc7_rgbaUnorm_srgb:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format is a YUV format.
    var isYUV: Bool {
        switch self {
        case .gbgr422, .bgrg422:
            return true
        default: return false
        }
    }

    /// Indicates if the format is a depth format.
    var isDepth: Bool {
        switch self {
        case .depth16Unorm, .depth32Float: return true
        default: return false
        }
    }
    
    /// Indicates if the format includes a stencil component.
    var isStencil: Bool {
        switch self {
        case .stencil8, .depth32Float_stencil8, .x32_stencil8:
            return true
        default: return false
        }
    }
    
    /// Indicates if the format can be used as a render target.
    var isRenderable: Bool {
        // Depth, stencil, YUV & compressed pixel formats check.
        guard !(self.isDepth || self.isStencil || self.isYUV || self.isCompressed)
        else { return false }

        switch self {
        case .a8Unorm:
            return false
        case .rgb9e5Float:
            #if os(iOS) && !targetEnvironment(macCatalyst)
            return true
            #elseif os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
            return false
            #endif
        default: return true
        }
    }
}
