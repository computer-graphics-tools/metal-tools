import MetalTools
import simd

/// A class that performs standard mean normalization on textures using Metal.
final public class StdMeanNormalization {
    // MARK: - Properties

    /// The compute pipeline state used for the normalization.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `StdMeanNormalization` using a Metal context.
    ///
    /// - Parameter context: The Metal context to use.
    /// - Throws: An error if the initialization fails.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Initializes a new instance of `StdMeanNormalization` using a Metal library.
    ///
    /// - Parameter library: The Metal library containing the kernel functions.
    /// - Throws: An error if the initialization fails.
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

    /// Encodes the normalization operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - mean: The mean values for normalization.
    ///   - std: The standard deviation values for normalization.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        mean: SIMD3<Float>,
        std: SIMD3<Float>,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            mean: mean,
            std: std,
            in: commandBuffer
        )
    }

    /// Encodes the normalization operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - mean: The mean values for normalization.
    ///   - std: The standard deviation values for normalization.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        mean: SIMD3<Float>,
        std: SIMD3<Float>,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            mean: mean,
            std: std,
            using: encoder
        )
    }

    /// Encodes the normalization operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - mean: The mean values for normalization.
    ///   - std: The standard deviation values for normalization.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        mean: SIMD3<Float>,
        std: SIMD3<Float>,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Normalize Kernel"
            self.encode(
                source: source,
                destination: destination,
                mean: mean,
                std: std,
                using: encoder
            )
        }
    }

    /// Encodes the normalization operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - mean: The mean values for normalization.
    ///   - std: The standard deviation values for normalization.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        mean: SIMD3<Float>,
        std: SIMD3<Float>,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, destination)
        encoder.setValue(mean, at: 0)
        encoder.setValue(std, at: 1)

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

    /// The name of the Metal kernel function used for normalization.
    public static let functionName = "normalization"
}
