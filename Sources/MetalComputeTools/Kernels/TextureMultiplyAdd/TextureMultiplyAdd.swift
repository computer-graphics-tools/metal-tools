import MetalTools

/// A class for performing texture multiply-add operations using Metal.
final public class TextureMultiplyAdd {
    // MARK: - Properties

    /// The Metal compute pipeline state for the multiply-add operation.
    public let pipelineState: MTLComputePipelineState

    /// A flag indicating if the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureMultiplyAdd`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - multiplier: The multiplier value for the multiply-add operation.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the multiply-add operation with the specified context and multiplier.
    public convenience init(
        context: MTLContext,
        multiplier: Float
    ) throws {
        try self.init(
            library: context.library(for: .module),
            multiplier: multiplier
        )
    }

    /// Creates a new instance of `TextureMultiplyAdd` with the specified library and multiplier.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the multiply-add operation.
    ///   - multiplier: The multiplier value for the multiply-add operation.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the multiply-add operation.
    public init(
        library: MTLLibrary,
        multiplier: Float
    ) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        constantValues.set(
            multiplier,
            at: 1
        )
        self.pipelineState = try library.computePipelineState(
            function: Self.functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the texture multiply-add operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the multiply-add operation using the provided textures and command buffer.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            in: commandBuffer
        )
    }

    /// Encodes the texture multiply-add operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the multiply-add operation using the provided textures and command encoder.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            using: encoder
        )
    }

    /// Encodes the texture multiply-add operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the multiply-add operation using the provided textures and command buffer.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Multiply Add"
            self.encode(
                sourceOne: sourceOne,
                sourceTwo: sourceTwo,
                destination: destination,
                using: encoder
            )
        }
    }

    /// Encodes the texture multiply-add operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the multiply-add operation using the provided textures and command encoder.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(sourceOne, sourceTwo, destination)

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

    /// The name of the Metal function used for texture multiply-add operations.
    public static let functionName = "textureMultiplyAdd"
}
