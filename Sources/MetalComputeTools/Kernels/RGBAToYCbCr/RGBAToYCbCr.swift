import MetalTools

/// A class that converts RGBA textures to YCbCr format using Metal.
final public class RGBAToYCbCr {
    // MARK: - Properties

    /// The compute pipeline state used for the RGBA to YCbCr conversion.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `RGBAToYCbCr` using a Metal context.
    ///
    /// - Parameters:
    ///   - context: The Metal context to use.
    ///   - halfSizedCbCr: Whether to use half-sized chroma components. Defaults to true.
    /// - Throws: An error if the initialization fails.
    public convenience init(
        context: MTLContext,
        halfSizedCbCr: Bool = true
    ) throws {
        try self.init(
            library: context.library(for: .module),
            halfSizedCbCr: halfSizedCbCr
        )
    }

    /// Initializes a new instance of `RGBAToYCbCr` using a Metal library.
    ///
    /// - Parameters:
    ///   - library: The Metal library containing the kernel functions.
    ///   - halfSizedCbCr: Whether to use half-sized chroma components. Defaults to true.
    /// - Throws: An error if the initialization fails.
    public init(
        library: MTLLibrary,
        halfSizedCbCr: Bool = true
    ) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        constantValues.set(
            halfSizedCbCr,
            at: 2
        )
        self.pipelineState = try library.computePipelineState(
            function: Self.functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the RGBA to YCbCr conversion into a command buffer.
    ///
    /// - Parameters:
    ///   - sourceRGBA: The source RGBA texture.
    ///   - destinationY: The destination texture for the Y component.
    ///   - destinationCbCr: The destination texture for the CbCr components.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        sourceRGBA: MTLTexture,
        destinationY: MTLTexture,
        destinationCbCr: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            sourceRGBA: sourceRGBA,
            destinationY: destinationY,
            destinationCbCr: destinationCbCr,
            in: commandBuffer
        )
    }

    /// Encodes the RGBA to YCbCr conversion using a compute command encoder.
    ///
    /// - Parameters:
    ///   - sourceRGBA: The source RGBA texture.
    ///   - destinationY: The destination texture for the Y component.
    ///   - destinationCbCr: The destination texture for the CbCr components.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        sourceRGBA: MTLTexture,
        destinationY: MTLTexture,
        destinationCbCr: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            sourceRGBA: sourceRGBA,
            destinationY: destinationY,
            destinationCbCr: destinationCbCr,
            using: encoder
        )
    }

    /// Encodes the RGBA to YCbCr conversion into a command buffer.
    ///
    /// - Parameters:
    ///   - sourceRGBA: The source RGBA texture.
    ///   - destinationY: The destination texture for the Y component.
    ///   - destinationCbCr: The destination texture for the CbCr components.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        sourceRGBA: MTLTexture,
        destinationY: MTLTexture,
        destinationCbCr: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "RGBA To YCbCr"
            self.encode(
                sourceRGBA: sourceRGBA,
                destinationY: destinationY,
                destinationCbCr: destinationCbCr,
                using: encoder
            )
        }
    }

    /// Encodes the RGBA to YCbCr conversion using a compute command encoder.
    ///
    /// - Parameters:
    ///   - sourceRGBA: The source RGBA texture.
    ///   - destinationY: The destination texture for the Y component.
    ///   - destinationCbCr: The destination texture for the CbCr components.
    ///   - encoder: The compute command encoder to use.
    private func encode(
        sourceRGBA: MTLTexture,
        destinationY: MTLTexture,
        destinationCbCr: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        #if DEBUG
        assert(
            sourceRGBA.size == destinationY.size,
            "RGBA and Y textures must have equal sizes."
        )
        #endif
        encoder.setTextures(
            sourceRGBA,
            destinationY,
            destinationCbCr
        )
        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(
                state: self.pipelineState,
                exactly: destinationCbCr.size
            )
        } else {
            encoder.dispatch2d(
                state: self.pipelineState,
                covering: destinationCbCr.size
            )
        }
    }

    /// The name of the Metal kernel function used for RGBA to YCbCr conversion.
    public static let functionName = "rgbaToYCbCr"
}
