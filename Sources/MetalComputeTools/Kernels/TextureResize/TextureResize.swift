import MetalTools

/// A class for performing texture resizing using Metal.
final public class TextureResize {
    // MARK: - Properties

    /// The Metal compute pipeline state for the resize operation.
    public let pipelineState: MTLComputePipelineState

    /// The Metal sampler state for texture sampling.
    private let samplerState: MTLSamplerState

    /// A flag indicating if the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureResize`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - minMagFilter: The min/mag filter to use for the sampler.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the resize operation with the specified context and min/mag filter.
    public convenience init(
        context: MTLContext,
        minMagFilter: MTLSamplerMinMagFilter
    ) throws {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = minMagFilter
        samplerDescriptor.magFilter = minMagFilter
        samplerDescriptor.normalizedCoordinates = true
        try self.init(
            context: context,
            samplerDescriptor: samplerDescriptor
        )
    }

    /// Creates a new instance of `TextureResize`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - samplerDescriptor: The sampler descriptor to use.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the resize operation with the specified context and sampler descriptor.
    public convenience init(
        context: MTLContext,
        samplerDescriptor: MTLSamplerDescriptor
    ) throws {
        try self.init(
            library: context.library(for: .module),
            samplerDescriptor: samplerDescriptor
        )
    }

    /// Creates a new instance of `TextureResize`.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use.
    ///   - minMagFilter: The min/mag filter to use for the sampler.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the resize operation with the specified library and min/mag filter.
    public convenience init(
        library: MTLLibrary,
        minMagFilter: MTLSamplerMinMagFilter
    ) throws {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = minMagFilter
        samplerDescriptor.magFilter = minMagFilter
        samplerDescriptor.normalizedCoordinates = true
        try self.init(
            library: library,
            samplerDescriptor: samplerDescriptor
        )
    }

    /// Creates a new instance of `TextureResize` with the specified library and sampler descriptor.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the resize operation.
    ///   - samplerDescriptor: The sampler descriptor to use.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state and sampler state for the resize operation.
    public init(
        library: MTLLibrary,
        samplerDescriptor: MTLSamplerDescriptor
    ) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device
            .supports(feature: .nonUniformThreadgroups)

        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )

        self.pipelineState = try library.computePipelineState(
            function: Self.functionName,
            constants: constantValues
        )
        guard let samplerState = library.device.makeSamplerState(descriptor: samplerDescriptor)
        else { throw MetalError.MTLDeviceError.samplerStateCreationFailed }
        self.samplerState = samplerState
    }

    // MARK: - Encode

    /// Encodes the texture resize operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the resize operation using the provided textures and command buffer.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            in: commandBuffer
        )
    }

    /// Encodes the texture resize operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the resize operation using the provided textures and command encoder.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            using: encoder
        )
    }

    /// Encodes the texture resize operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the resize operation using the provided textures and command buffer.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Resize"
            self.encode(
                source: source,
                destination: destination,
                using: encoder
            )
        }
    }

    /// Encodes the texture resize operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the resize operation using the provided textures and command encoder.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, destination)

        encoder.setSamplerState(
            self.samplerState,
            index: 0
        )

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

    /// The name of the Metal function used for texture resizing.
    public static let functionName = "textureResize"
}
