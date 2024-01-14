import Metal

public enum Features {
    case nonUniformThreadgroups
    case tileShaders
    case readWriteTextures(MTLPixelFormat)
    case readWriteCubeMapTexturesInFunctions
}

public extension MTLDevice {
    func supports(feature: Features) -> Bool {
        switch feature {
        case .nonUniformThreadgroups:
            #if targetEnvironment(macCatalyst)
            return supportsFamily(.common3)
            #elseif os(iOS)
            return supportsFeatureSet(.iOS_GPUFamily4_v1)
            #elseif os(macOS)
            return supportsFeatureSet(.macOS_GPUFamily1_v3)
            #endif
        case .tileShaders: return supportsFamily(.apple4)
        case let .readWriteTextures(pixelFormat):
            let tierOneSupportedPixelFormats: Set<MTLPixelFormat> = [
                .r32Float, .r32Uint, .r32Sint
            ]
            let tierTwoSupportedPixelFormats: Set<MTLPixelFormat> = tierOneSupportedPixelFormats.union([
                .rgba32Float, .rgba32Uint, .rgba32Sint, .rgba16Float,
                .rgba16Uint, .rgba16Sint, .rgba8Unorm, .rgba8Uint,
                .rgba8Sint, .r16Float, .r16Uint, .r16Sint,
                .r8Unorm, .r8Uint, .r8Sint
            ])

            switch readWriteTextureSupport {
            case .tier1: return tierOneSupportedPixelFormats.contains(pixelFormat)
            case .tier2: return tierTwoSupportedPixelFormats.contains(pixelFormat)
            case .tierNone: return false
            @unknown default: return false
            }
        case .readWriteCubeMapTexturesInFunctions:
            var familiesWithReadWriteCubeMapSupport: [MTLGPUFamily] = [
                .apple4, .apple5, .apple6, .apple7, .apple8, .mac2
            ]
            if #available(iOS 16.0, macOS 13.0, *) {
                familiesWithReadWriteCubeMapSupport.append(.metal3)
            }
            for family in familiesWithReadWriteCubeMapSupport where supportsFamily(family) {
                return true
            }
            return false
        }
    }
}
