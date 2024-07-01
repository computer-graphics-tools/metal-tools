import MetalTools
import simd

/// A class that performs affine cropping on textures using Metal.
final public class TextureAffineCrop {
    // MARK: - Properties

    /// The compute pipeline state used for the affine crop operation.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `TextureAffineCrop` using a Metal context.
    ///
    /// - Parameter context: The Metal context to use.
    /// - Throws: An error if the initialization fails.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Initializes a new instance of `TextureAffineCrop` using a Metal library.
    ///
    /// - Parameter library: The Metal library containing the kernel functions.
    /// - Throws: An error if the initialization fails.
    public init(library: MTLLibrary) throws {
        let functionName = Self.functionName
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        self.pipelineState = try library.computePipelineState(
            function: functionName,
            constants:  constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the affine crop operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - affineTransform: The 3x3 affine transformation matrix.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        affineTransform: simd_float3x3,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            affineTransform: affineTransform,
            in: commandBuffer
        )
    }

    /// Encodes the affine crop operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - affineTransform: The 3x3 affine transformation matrix.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        affineTransform: simd_float3x3,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            affineTransform: affineTransform,
            using: encoder
        )
    }

    /// Encodes the affine crop operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - affineTransform: The 3x3 affine transformation matrix.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        affineTransform: simd_float3x3,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Affine Crop"
            self.encode(
                source: source,
                destination: destination,
                affineTransform: affineTransform,
                using: encoder
            )
        }
    }

    /// Encodes the affine crop operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - affineTransform: The 3x3 affine transformation matrix.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        affineTransform: simd_float3x3,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, destination)
        encoder.setValue(affineTransform, at: 0)

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

    /// The name of the Metal kernel function used for affine cropping.
    public static let functionName = "textureAffineCrop"
}
