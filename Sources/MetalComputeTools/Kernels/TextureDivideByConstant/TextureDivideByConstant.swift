import MetalTools
import simd

/// A class for performing texture division by a constant using Metal.
final public class TextureDivideByConstant {
    // MARK: - Properties

    /// The Metal compute pipeline state for the divide by constant operation.
    private let pipelineState: MTLComputePipelineState
    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Init
    
    /// Creates a new instance of `TextureDivideByConstant`.
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
    
    /// Creates a new instance of `TextureDivideByConstant`.
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
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
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
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
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
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        constant: SIMD4<Float>,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Divide by Constant"
            self.encode(
                source: source,
                destination: destination,
                constant: constant,
                using: encoder
            )
        }
    }
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
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
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        constant: MTLBuffer,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            constant: constant,
            in: commandBuffer
        )
    }
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        constant: MTLBuffer,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            constant: constant,
            using: encoder
        )
    }
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        constant: MTLBuffer,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Divide by Constant"
            self.encode(
                source: source,
                destination: destination,
                constant: constant,
                using: encoder
            )
        }
    }
    
    /// Encodes the texture division by a constant operation.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - constant: The constant value to divide the texture by.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        constant: MTLBuffer,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.setTextures(source, destination)
        encoder.setBuffer(constant, offset: 0, index: 0)

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

    public static let functionName = "divideByConstant"
}
