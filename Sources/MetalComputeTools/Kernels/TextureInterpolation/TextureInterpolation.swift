import MetalTools

/// A class for performing texture interpolation using Metal.
final public class TextureInterpolation {
    // MARK: - Properties

    /// The Metal compute pipeline state for the interpolation operation.
    public let pipelineState: MTLComputePipelineState

    /// A flag indicating if the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Init

    /// Creates a new instance of `TextureInterpolation`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - scalarType: The scalar type for the interpolation operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the interpolation operation with the specified context and scalar type.
    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Creates a new instance of `TextureInterpolation` with the specified library and scalar type.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the interpolation.
    ///   - scalarType: The scalar type for the interpolation operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the interpolation operation.
    public init(
        library: MTLLibrary,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)

        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        let functionName = Self.functionName + "_" + scalarType.rawValue
        self.pipelineState = try library.computePipelineState(
            function: functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the texture interpolation operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the interpolation.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the interpolation operation using the provided textures, weight, and command buffer.
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

    /// Encodes the texture interpolation operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the interpolation.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the interpolation operation using the provided textures, weight, and command encoder.
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

    /// Encodes the texture interpolation operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the interpolation.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the interpolation operation using the provided textures, weight, and command buffer.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        weight: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Interpolation"
            self.encode(
                sourceOne: sourceOne,
                sourceTwo: sourceTwo,
                destination: destination,
                weight: weight,
                using: encoder
            )
        }
    }

    /// Encodes the texture interpolation operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - weight: The weight value for the interpolation.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the interpolation operation using the provided textures, weight, and command encoder.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        weight: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(sourceOne, sourceTwo, destination)
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

    /// The name of the Metal function used for texture interpolation.
    public static let functionName = "textureInterpolation"
}
