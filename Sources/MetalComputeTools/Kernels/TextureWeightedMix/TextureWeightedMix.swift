import MetalTools

/// A class for performing weighted mixing of textures using Metal.
final public class TextureWeightedMix {
    // MARK: - Properties

    /// The Metal compute pipeline state for the weighted mix operation.
    public let pipelineState: MTLComputePipelineState

    /// A flag indicating if the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureWeightedMix`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the weighted mix operation with the specified context.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Creates a new instance of `TextureWeightedMix` with the specified library.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the weighted mix operation.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the weighted mix operation.
    public init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        self.pipelineState = try library.computePipelineState(
            function: Self.functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the weighted mix operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the mix operation.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the weighted mix operation using the provided textures, weight, and command buffer.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        weight: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            weight: weight,
            in: commandBuffer
        )
    }

    /// Encodes the weighted mix operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the mix operation.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the weighted mix operation using the provided textures, weight, and command encoder.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        weight: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            weight: weight,
            using: encoder
        )
    }

    /// Encodes the weighted mix operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the mix operation.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the weighted mix operation using the provided textures, weight, and command buffer.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        weight: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Mix"
            self.encode(
                sourceOne: sourceOne,
                sourceTwo: sourceTwo,
                destination: destination,
                weight: weight,
                using: encoder
            )
        }
    }

    /// Encodes the weighted mix operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the mix operation.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the weighted mix operation using the provided textures, weight, and command encoder.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        weight: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(
            sourceOne,
            sourceTwo,
            destination
        )
        encoder.setValue(weight, at: 0)
        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(
                state: self.pipelineState,
                exactly: destination.size
            )
        } else {
            encoder.dispatch2d(
                state: self.pipelineState,
                covering: destination.size
            )
        }
    }

    /// The name of the Metal function used for texture weighted mixing.
    public static let functionName = "textureWeightedMix"
}
