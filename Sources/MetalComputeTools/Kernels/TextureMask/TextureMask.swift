import MetalTools
import Metal

/// A class for applying a mask to a texture using Metal.
final public class TextureMask {
    // MARK: - Properties

    /// The Metal compute pipeline state for the mask operation.
    public let pipelineState: MTLComputePipelineState

    /// A flag indicating if the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureMask`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - scalarType: The scalar type for the mask operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the mask operation with the specified context and scalar type.
    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Creates a new instance of `TextureMask` with the specified library and scalar type.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the mask operation.
    ///   - scalarType: The scalar type for the mask operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the mask operation.
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

    /// Encodes the texture mask operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture to be masked.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - isInversed: A flag indicating if the mask should be inversed. Defaults to `false`.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the mask operation using the provided textures, flag, and command buffer.
    public func callAsFunction(
        source: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        isInversed: Bool = false,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            mask: mask,
            destination: destination,
            isInversed: isInversed,
            in: commandBuffer
        )
    }

    /// Encodes the texture mask operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture to be masked.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - isInversed: A flag indicating if the mask should be inversed. Defaults to `false`.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the mask operation using the provided textures, flag, and command encoder.
    public func callAsFunction(
        source: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        isInversed: Bool = false,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            mask: mask,
            destination: destination,
            isInversed: isInversed,
            using: encoder
        )
    }

    /// Encodes the texture mask operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture to be masked.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - isInversed: A flag indicating if the mask should be inversed. Defaults to `false`.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the mask operation using the provided textures, flag, and command buffer.
    public func encode(
        source: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        isInversed: Bool = false,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Mask"
            self.encode(
                source: source,
                mask: mask,
                destination: destination,
                isInversed: isInversed,
                using: encoder
            )
        }
    }

    /// Encodes the texture mask operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture to be masked.
    ///   - mask: The mask texture.
    ///   - destination: The destination texture.
    ///   - isInversed: A flag indicating if the mask should be inversed. Defaults to `false`.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the mask operation using the provided textures, flag, and command encoder.
    public func encode(
        source: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        isInversed: Bool = false,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, mask, destination)
        encoder.setValue(isInversed, at: 0)

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

    /// The name of the Metal function used for texture masking.
    public static let functionName = "textureMask"
}
