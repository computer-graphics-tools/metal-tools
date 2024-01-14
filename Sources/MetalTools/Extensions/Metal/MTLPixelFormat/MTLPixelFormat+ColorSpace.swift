import CoreGraphics
import Metal

extension MTLPixelFormat {
    func colorSpace(layerColorSpace: CGColorSpace? = nil) -> CGColorSpace? {
        switch self {
        case .a8Unorm, .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint, .r8Sint, .r16Unorm, .r16Snorm, .r16Uint, .r16Sint,
             .r16Float, .r32Uint, .r32Sint, .r32Float:
            return layerColorSpace ?? CGColorSpaceCreateDeviceGray()
        case .rgba8Unorm, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .b5g6r5Unorm, .a1bgr5Unorm, .bgr5A1Unorm,
             .rgb10a2Unorm, .rgb10a2Uint, .bgr10a2Unorm, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint:
            return layerColorSpace ?? CGColorSpace(name: CGColorSpace.linearSRGB)
        case .rgba8Unorm_srgb, .bgra8Unorm_srgb:
            return layerColorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)
        case .rgba16Float, .bgr10_xr:
            return layerColorSpace ?? CGColorSpace(name: CGColorSpace.extendedLinearSRGB)
        case .bgr10_xr_srgb:
            return layerColorSpace ?? CGColorSpace(name: CGColorSpace.extendedSRGB)
        case .invalid, .rg8Unorm, .rg16Snorm, .rg8Unorm_srgb, .rg8Snorm, .rg8Uint, .rg8Sint, .abgr4Unorm, .rg16Unorm,
             .rg16Uint, .rg16Sint, .rg16Float, .rg11b10Float, .rgb9e5Float, .rg32Uint, .rg32Sint, .rg32Float,
             .bgra10_xr, .bgra10_xr_srgb, .rgba32Uint, .rgba32Sint, .rgba32Float, .bc1_rgba, .bc1_rgba_srgb,
             .bc2_rgba, .bc2_rgba_srgb, .bc3_rgba, .bc3_rgba_srgb, .bc4_rUnorm, .bc4_rSnorm, .bc5_rgUnorm,
             .bc5_rgSnorm, .bc6H_rgbFloat, .bc6H_rgbuFloat, .bc7_rgbaUnorm, .bc7_rgbaUnorm_srgb, .pvrtc_rgb_2bpp,
             .pvrtc_rgb_2bpp_srgb, .pvrtc_rgb_4bpp, .pvrtc_rgb_4bpp_srgb, .pvrtc_rgba_2bpp, .pvrtc_rgba_2bpp_srgb,
             .pvrtc_rgba_4bpp, .pvrtc_rgba_4bpp_srgb, .eac_r11Unorm, .eac_r11Snorm, .eac_rg11Unorm, .eac_rg11Snorm,
             .eac_rgba8, .eac_rgba8_srgb, .etc2_rgb8, .etc2_rgb8_srgb, .etc2_rgb8a1, .etc2_rgb8a1_srgb,
             .astc_4x4_srgb, .astc_5x4_srgb, .astc_5x5_srgb, .astc_6x5_srgb, .astc_6x6_srgb, .astc_8x5_srgb,
             .astc_8x6_srgb, .astc_8x8_srgb, .astc_10x5_srgb, .astc_10x6_srgb, .astc_10x8_srgb, .astc_10x10_srgb,
             .astc_12x10_srgb, .astc_12x12_srgb, .astc_4x4_ldr, .astc_5x4_ldr, .astc_5x5_ldr, .astc_6x5_ldr,
             .astc_6x6_ldr, .astc_8x5_ldr, .astc_8x6_ldr, .astc_8x8_ldr, .astc_10x5_ldr, .astc_10x6_ldr,
             .astc_10x8_ldr, .astc_10x10_ldr, .astc_12x10_ldr, .astc_12x12_ldr, .astc_4x4_hdr, .astc_5x4_hdr,
             .astc_5x5_hdr, .astc_6x5_hdr, .astc_6x6_hdr, .astc_8x5_hdr, .astc_8x6_hdr, .astc_8x8_hdr,
             .astc_10x5_hdr, .astc_10x6_hdr, .astc_10x8_hdr, .astc_10x10_hdr, .astc_12x10_hdr, .astc_12x12_hdr,
             .gbgr422, .bgrg422, .depth16Unorm, .depth32Float, .stencil8, .depth24Unorm_stencil8,
             .depth32Float_stencil8, .x32_stencil8, .x24_stencil8:
            return nil
        @unknown default:
            return nil
        }
    }
}
