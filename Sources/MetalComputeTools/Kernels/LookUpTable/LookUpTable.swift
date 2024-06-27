import MetalTools
import Metal

/// A class that applies a look-up table (LUT) to an image using Metal.
final public class LookUpTable {
    // MARK: - Properties

    /// The compute pipeline state used for applying the look-up table.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `LookUpTable` using a Metal context.
    ///
    /// - Parameter context: The Metal context to use.
    /// - Throws: An error if the initialization fails.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Initializes a new instance of `LookUpTable` using a Metal library.
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
        let functionName = Self.functionName
        self.pipelineState = try library.computePipelineState(
            function: functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the look-up table application into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - lut: The look-up table texture.
    ///   - intensity: The intensity of the LUT application (0.0 - 1.0).
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        lut: MTLTexture,
        intensity: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            lut: lut,
            intensity: intensity,
            in: commandBuffer
        )
    }

    /// Encodes the look-up table application using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - lut: The look-up table texture.
    ///   - intensity: The intensity of the LUT application (0.0 - 1.0).
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        lut: MTLTexture,
        intensity: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            lut: lut,
            intensity: intensity,
            using: encoder
        )
    }

    /// Encodes the look-up table application into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - lut: The look-up table texture.
    ///   - intensity: The intensity of the LUT application (0.0 - 1.0).
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        lut: MTLTexture,
        intensity: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Look Up Table"
            self.encode(
                source: source,
                destination: destination,
                lut: lut,
                intensity: intensity,
                using: encoder
            )
        }
    }

    /// Encodes the look-up table application using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - lut: The look-up table texture.
    ///   - intensity: The intensity of the LUT application (0.0 - 1.0).
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        lut: MTLTexture,
        intensity: Float,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, destination, lut)
        encoder.setValue(intensity, at: 0)

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

    /// The name of the Metal kernel function used for look-up table application.
    public static let functionName = "lookUpTable"
}
