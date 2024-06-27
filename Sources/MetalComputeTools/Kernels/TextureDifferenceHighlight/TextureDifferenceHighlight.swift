import MetalTools
import Metal

/// A class that highlights differences between two textures using Metal.
final public class TextureDifferenceHighlight {
    // MARK: - Properties

    /// The compute pipeline state used for the difference highlighting operation.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `TextureDifferenceHighlight` using a Metal context.
    ///
    /// - Parameter context: The Metal context to use.
    /// - Throws: An error if the initialization fails.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Initializes a new instance of `TextureDifferenceHighlight` using a Metal library.
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

    /// Encodes the difference highlighting operation into a command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture to compare against.
    ///   - destination: The destination texture where the result will be stored.
    ///   - color: The color to use for highlighting differences.
    ///   - threshold: The threshold value for considering pixels different.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        color: SIMD4<Float>,
        threshold: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            color: color,
            threshold: threshold,
            in: commandBuffer
        )
    }

    /// Encodes the difference highlighting operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture to compare against.
    ///   - destination: The destination texture where the result will be stored.
    ///   - color: The color to use for highlighting differences.
    ///   - threshold: The threshold value for considering pixels different.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        color: SIMD4<Float>,
        threshold: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            color: color,
            threshold: threshold,
            using: encoder
        )
    }

    /// Encodes the difference highlighting operation into a command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture to compare against.
    ///   - destination: The destination texture where the result will be stored.
    ///   - color: The color to use for highlighting differences.
    ///   - threshold: The threshold value for considering pixels different.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        color: SIMD4<Float>,
        threshold: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Difference Highlight"
            self.encode(
                sourceOne: sourceOne,
                sourceTwo: sourceTwo,
                destination: destination,
                color: color,
                threshold: threshold,
                using: encoder
            )
        }
    }

    /// Encodes the difference highlighting operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture to compare against.
    ///   - destination: The destination texture where the result will be stored.
    ///   - color: The color to use for highlighting differences.
    ///   - threshold: The threshold value for considering pixels different.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        color: SIMD4<Float>,
        threshold: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(sourceOne, sourceTwo, destination)
        encoder.setValue(color, at: 0)
        encoder.setValue(threshold, at: 1)

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

    /// The name of the Metal kernel function used for texture difference highlighting.
    public static let functionName = "textureDifferenceHighlight"
}
