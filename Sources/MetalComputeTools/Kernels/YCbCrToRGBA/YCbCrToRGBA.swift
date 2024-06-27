import MetalTools
import Metal

/// A class for converting YCbCr textures to RGBA format using Metal.
final public class YCbCrToRGBA {
    // MARK: - Properties

    /// The Metal compute pipeline state for the YCbCr to RGBA conversion operation.
    public let pipelineState: MTLComputePipelineState

    /// A flag indicating if the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Creates a new instance of `YCbCrToRGBA`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the YCbCr to RGBA conversion operation with the specified context.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Creates a new instance of `YCbCrToRGBA` with the specified library.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the conversion operation.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the YCbCr to RGBA conversion operation.
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

    /// Encodes the YCbCr to RGBA conversion operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceY: The source Y texture.
    ///   - sourceCbCr: The source CbCr texture.
    ///   - destinationRGBA: The destination RGBA texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the conversion operation using the provided textures and command buffer.
    public func callAsFunction(
        sourceY: MTLTexture,
        sourceCbCr: MTLTexture,
        destinationRGBA: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            sourceY: sourceY,
            sourceCbCr: sourceCbCr,
            destinationRGBA: destinationRGBA,
            in: commandBuffer
        )
    }

    /// Encodes the YCbCr to RGBA conversion operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceY: The source Y texture.
    ///   - sourceCbCr: The source CbCr texture.
    ///   - destinationRGBA: The destination RGBA texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the conversion operation using the provided textures and command encoder.
    public func callAsFunction(
        sourceY: MTLTexture,
        sourceCbCr: MTLTexture,
        destinationRGBA: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            sourceY: sourceY,
            sourceCbCr: sourceCbCr,
            destinationRGBA: destinationRGBA,
            using: encoder
        )
    }

    /// Encodes the YCbCr to RGBA conversion operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceY: The source Y texture.
    ///   - sourceCbCr: The source CbCr texture.
    ///   - destinationRGBA: The destination RGBA texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the conversion operation using the provided textures and command buffer.
    public func encode(
        sourceY: MTLTexture,
        sourceCbCr: MTLTexture,
        destinationRGBA: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "YCbCr To RGBA"
            self.encode(
                sourceY: sourceY,
                sourceCbCr: sourceCbCr,
                destinationRGBA: destinationRGBA,
                using: encoder
            )
        }
    }

    /// Encodes the YCbCr to RGBA conversion operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceY: The source Y texture.
    ///   - sourceCbCr: The source CbCr texture.
    ///   - destinationRGBA: The destination RGBA texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the conversion operation using the provided textures and command encoder.
    public func encode(
        sourceY: MTLTexture,
        sourceCbCr: MTLTexture,
        destinationRGBA: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(sourceY, sourceCbCr, destinationRGBA)

        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(
                state: self.pipelineState,
                exactly: destinationRGBA.size
            )
        } else {
            encoder.dispatch2d(
                state: self.pipelineState,
                covering: destinationRGBA.size
            )
        }
    }

    /// The name of the Metal function used for YCbCr to RGBA conversion.
    public static let functionName = "ycbcrToRGBA"
}
