import MetalTools

/// A class that adds a constant value to a texture using Metal.
final public class TextureAddConstant {
    // MARK: - Properties

    /// The compute pipeline state used for adding the constant.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Init

    /// Initializes a new instance of `TextureAddConstant` using a Metal context.
    ///
    /// - Parameters:
    ///   - context: The Metal context to use.
    ///   - scalarType: The scalar type for the computation. Defaults to `.half`.
    /// - Throws: An error if the initialization fails.
    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Initializes a new instance of `TextureAddConstant` using a Metal library.
    ///
    /// - Parameters:
    ///   - library: The Metal library containing the kernel functions.
    ///   - scalarType: The scalar type for the computation. Defaults to `.half`.
    /// - Throws: An error if the initialization fails.
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

    /// Encodes the constant addition operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to add to each pixel.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        constant: SIMD4<Float>,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            constant: constant,
            in: commandBuffer
        )
    }

    /// Encodes the constant addition operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to add to each pixel.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        constant: SIMD4<Float>,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            constant: constant,
            using: encoder
        )
    }

    /// Encodes the constant addition operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to add to each pixel.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        constant: SIMD4<Float>,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Add Constant"
            self.encode(
                source: source,
                destination: destination,
                constant: constant,
                using: encoder
            )
        }
    }

    /// Encodes the constant addition operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to add to each pixel.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        constant: SIMD4<Float>,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, destination)
        encoder.setValue(constant, at: 0)

        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(
                state: self.pipelineState,
                exactly: source.size
            )
        } else {
            encoder.dispatch2d(
                state: self.pipelineState,
                covering: source.size
            )
        }
    }

    /// The name of the Metal kernel function used for adding a constant to a texture.
    public static let functionName = "addConstant"
}
