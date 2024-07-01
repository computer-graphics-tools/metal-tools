import MetalTools

/// A class for performing masked mixing of textures using Metal.
final public class TextureMaskedMix {
    // MARK: - Properties

    /// The Metal compute pipeline state for the masked mix operation.
    public let pipelineState: MTLComputePipelineState

    /// A flag indicating if the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureMaskedMix`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the masked mix operation with the specified context.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Creates a new instance of `TextureMaskedMix` with the specified library.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the masked mix operation.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the masked mix operation.
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

    /// Encodes the texture masked mix operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the masked mix operation using the provided textures and command buffer.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            mask: mask,
            destination: destination,
            in: commandBuffer
        )
    }

    /// Encodes the texture masked mix operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the masked mix operation using the provided textures and command encoder.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            mask: mask,
            destination: destination,
            using: encoder
        )
    }

    /// Encodes the texture masked mix operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the masked mix operation using the provided textures and command buffer.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Mix"
            self.encode(
                sourceOne: sourceOne,
                sourceTwo: sourceTwo,
                mask: mask,
                destination: destination,
                using: encoder
            )
        }
    }

    /// Encodes the texture masked mix operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the masked mix operation using the provided textures and command encoder.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(sourceOne, sourceTwo, mask, destination)
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

    /// The name of the Metal function used for texture masked mixing.
    public static let functionName = "textureMaskedMix"
}
