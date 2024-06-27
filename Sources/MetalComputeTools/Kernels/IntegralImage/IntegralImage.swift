import MetalTools
import Metal

/// A class that computes the integral image of a texture using Metal.
final public class IntegralImage {

    // MARK: - Properties

    /// The compute pipeline state used for integral image calculation.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `IntegralImage` using a Metal context.
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

    /// Initializes a new instance of `IntegralImage` using a Metal library.
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

    /// Encodes the integral image computation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture to store the integral image.
    ///   - commandBuffer: The command buffer to encode into.
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
    
    /// Encodes the integral image computation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture to store the integral image.
    ///   - encoder: The compute command encoder to use.
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
    
    /// Encodes the integral image computation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture to store the integral image.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Integral Image"
            self.encode(
                source: source,
                destination: destination,
                using: encoder
            )
        }
    }
    
    /// Encodes the integral image computation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture to store the integral image.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encodePass(
            source: source,
            destination: destination,
            isHorisontalPass: true,
            using: encoder
        )
        self.encodePass(
            source: destination,
            destination: destination,
            isHorisontalPass: false,
            using: encoder
        )
    }

    /// Encodes a single pass (horizontal or vertical) of the integral image computation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - isHorisontalPass: Whether this is a horizontal pass (true) or vertical pass (false).
    ///   - encoder: The compute command encoder to use.
    private func encodePass(
        source: MTLTexture,
        destination: MTLTexture,
        isHorisontalPass: Bool,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.pushDebugGroup("Integral Image \(isHorisontalPass ? "Horisontal" : "Vertical") Pass")
        defer { encoder.popDebugGroup() }

        encoder.setTextures(source, destination)
        encoder.setValue(isHorisontalPass, at: 0)

        let gridSize = isHorisontalPass ? destination.size.height : destination.size.width

        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch1d(
                state: self.pipelineState,
                exactly: gridSize
            )
        } else {
            encoder.dispatch1d(
                state: self.pipelineState,
                covering: gridSize
            )
        }
    }

    /// The name of the Metal kernel function used for integral image calculation.
    public static let functionName = "integralImage"
}
