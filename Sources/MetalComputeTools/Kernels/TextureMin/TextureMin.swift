import MetalTools
import Metal

/// A class for performing minimum value extraction from a texture using Metal.
final public class TextureMin {
    // MARK: - Properties

    /// The Metal compute pipeline state for the minimum value extraction operation.
    public let pipelineState: MTLComputePipelineState

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureMin`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - scalarType: The scalar type for the minimum value extraction operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the minimum value extraction operation with the specified context and scalar type.
    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Creates a new instance of `TextureMin` with the specified library and scalar type.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the minimum value extraction operation.
    ///   - scalarType: The scalar type for the minimum value extraction operation. Defaults to `.half`.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the minimum value extraction operation.
    public init(
        library: MTLLibrary,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        let functionName = Self.functionName + "_" + scalarType.rawValue
        self.pipelineState = try library.computePipelineState(function: functionName)
    }

    // MARK: - Encode

    /// Encodes the minimum value extraction operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the minimum value.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the minimum value extraction operation using the provided texture, result buffer, and command buffer.
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

    /// Encodes the minimum value extraction operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the minimum value.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the minimum value extraction operation using the provided texture, result buffer, and command encoder.
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

    /// Encodes the minimum value extraction operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the minimum value.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the minimum value extraction operation using the provided texture, result buffer, and command buffer.
    public func encode(
        source: MTLTexture,
        result: MTLBuffer,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Min"
            self.encode(
                source: source,
                result: result,
                using: encoder
            )
        }
    }

    /// Encodes the minimum value extraction operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - result: The buffer to store the minimum value.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the minimum value extraction operation using the provided texture, result buffer, and command encoder.
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

    /// The name of the Metal function used for minimum value extraction.
    public static let functionName = "textureMin"
}
