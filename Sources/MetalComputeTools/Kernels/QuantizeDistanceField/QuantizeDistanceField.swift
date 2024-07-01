import MetalTools

/// A class that quantizes a distance field using Metal.
final public class QuantizeDistanceField {
    // MARK: - Properties

    /// The compute pipeline state used for quantizing the distance field.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `QuantizeDistanceField` using a Metal context.
    ///
    /// - Parameter context: The Metal context to use.
    /// - Throws: An error if the initialization fails.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Initializes a new instance of `QuantizeDistanceField` using a Metal library.
    ///
    /// - Parameter library: The Metal library containing the kernel functions.
    /// - Throws: An error if the initialization fails.
    public init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(self.deviceSupportsNonuniformThreadgroups, at: 0)
        self.pipelineState = try library.computePipelineState(
            function: Self.functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the distance field quantization into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture containing the distance field.
    ///   - destination: The destination texture for the quantized result.
    ///   - normalizationFactor: The factor used to normalize the distance field values.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        normalizationFactor: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            normalizationFactor: normalizationFactor,
            in: commandBuffer
        )
    }

    /// Encodes the distance field quantization using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture containing the distance field.
    ///   - destination: The destination texture for the quantized result.
    ///   - normalizationFactor: The factor used to normalize the distance field values.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        normalizationFactor: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            normalizationFactor: normalizationFactor,
            using: encoder
        )
    }

    /// Encodes the distance field quantization into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture containing the distance field.
    ///   - destination: The destination texture for the quantized result.
    ///   - normalizationFactor: The factor used to normalize the distance field values.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        normalizationFactor: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Quantize Distance Field"
            self.encode(
                source: source,
                destination: destination,
                normalizationFactor: normalizationFactor,
                using: encoder
            )
        }
    }

    /// Encodes the distance field quantization using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture containing the distance field.
    ///   - destination: The destination texture for the quantized result.
    ///   - normalizationFactor: The factor used to normalize the distance field values.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        normalizationFactor: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, destination)
        encoder.setValue(normalizationFactor, at: 0)

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

    /// The name of the Metal kernel function used for quantizing the distance field.
    public static let functionName = "quantizeDistanceField"
}
