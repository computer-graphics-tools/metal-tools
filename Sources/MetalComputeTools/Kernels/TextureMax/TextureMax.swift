import MetalTools
import Metal

/// A class for performing maximum value extraction from a texture using Metal.
final public class TextureMax {
    // MARK: - Properties

    /// The Metal compute pipeline state for the maximum value extraction operation.
    public let pipelineState: MTLComputePipelineState

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureMax`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - scalarType: The scalar type for the maximum value extraction operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the maximum value extraction operation with the specified context and scalar type.
    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Creates a new instance of `TextureMax` with the specified library and scalar type.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the maximum value extraction operation.
    ///   - scalarType: The scalar type for the maximum value extraction operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the maximum value extraction operation.
    public init(
        library: MTLLibrary,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        let functionName = Self.functionName + "_" + scalarType.rawValue
        self.pipelineState = try library.computePipelineState(function: functionName)
    }

    // MARK: - Encode

    /// Encodes the maximum value extraction operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the maximum value.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the maximum value extraction operation using the provided texture, result buffer, and command buffer.
    public func callAsFunction(
        source: MTLTexture,
        result: MTLBuffer,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            result: result,
            in: commandBuffer
        )
    }

    /// Encodes the maximum value extraction operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the maximum value.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the maximum value extraction operation using the provided texture, result buffer, and command encoder.
    public func callAsFunction(
        source: MTLTexture,
        result: MTLBuffer,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            result: result,
            using: encoder
        )
    }

    /// Encodes the maximum value extraction operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the maximum value.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the maximum value extraction operation using the provided texture, result buffer, and command buffer.
    public func encode(
        source: MTLTexture,
        result: MTLBuffer,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Max"
            self.encode(
                source: source,
                result: result,
                using: encoder
            )
        }
    }

    /// Encodes the maximum value extraction operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the maximum value.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the maximum value extraction operation using the provided texture, result buffer, and command encoder.
    public func encode(
        source: MTLTexture,
        result: MTLBuffer,
        using encoder: MTLComputeCommandEncoder
    ) {
        let threadgroupSize = MTLSize(width: 8, height: 8, depth: 1).clamped(to: source.size)
        let blockSizeWidth = (source.width + threadgroupSize.width - 1) / threadgroupSize.width
        let blockSizeHeight = (source.height + threadgroupSize.height - 1) / threadgroupSize.height
        let blockSize = SIMD2<UInt16>(
            x: .init(blockSizeWidth),
            y: .init(blockSizeHeight)
        )

        encoder.setTextures(source)
        encoder.setValue(blockSize, at: 0)
        encoder.setBuffer(
            result,
            offset: 0,
            index: 1
        )

        let threadgroupMemoryLength = threadgroupSize.width * threadgroupSize.height * MemoryLayout<SIMD4<Float>>.stride

        encoder.setThreadgroupMemoryLength(
            threadgroupMemoryLength,
            index: 0
        )
        encoder.dispatch2d(
            state: self.pipelineState,
            covering: .one,
            threadgroupSize: threadgroupSize
        )
    }

    /// The name of the Metal function used for maximum value extraction.
    public static let functionName = "textureMax"
}
