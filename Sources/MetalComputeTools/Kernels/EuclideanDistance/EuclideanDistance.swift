import MetalTools

/// A class that calculates the Euclidean distance between two textures using Metal.
final public class EuclideanDistance {
    // MARK: - Properties

    /// The compute pipeline state used for the Euclidean distance calculation.
    public let pipelineState: MTLComputePipelineState

    // MARK: - Life Cycle

    /// Initializes a new instance of `EuclideanDistance` using a Metal context.
    ///
    /// - Parameters:
    ///   - context: The Metal context to use.
    ///   - scalarType: The scalar type for the computation. Defaults to `.half`.
    /// - Throws: An error if the initialization fails.
    convenience public init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Initializes a new instance of `EuclideanDistance` using a Metal library.
    ///
    /// - Parameters:
    ///   - library: The Metal library containing the kernel functions.
    ///   - scalarType: The scalar type for the computation. Defaults to `.half`.
    /// - Throws: An error if the initialization fails.
    public init(
        library: MTLLibrary,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        let functionName = Self.functionName + "_" + scalarType.rawValue
        self.pipelineState = try library.computePipelineState(function: functionName)
    }

    // MARK: - Encode

    /// Encodes the Euclidean distance computation into a command buffer.
    ///
    /// - Parameters:
    ///   - textureOne: The first input texture.
    ///   - textureTwo: The second input texture.
    ///   - resultBuffer: The buffer to store the result.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        textureOne: MTLTexture,
        textureTwo: MTLTexture,
        resultBuffer: MTLBuffer,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            textureOne: textureOne,
            textureTwo: textureTwo,
            resultBuffer: resultBuffer,
            in: commandBuffer
        )
    }

    /// Encodes the Euclidean distance computation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - textureOne: The first input texture.
    ///   - textureTwo: The second input texture.
    ///   - resultBuffer: The buffer to store the result.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        textureOne: MTLTexture,
        textureTwo: MTLTexture,
        resultBuffer: MTLBuffer,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            textureOne: textureOne,
            textureTwo: textureTwo,
            resultBuffer: resultBuffer,
            using: encoder
        )
    }

    /// Encodes the Euclidean distance computation into a command buffer.
    ///
    /// - Parameters:
    ///   - textureOne: The first input texture.
    ///   - textureTwo: The second input texture.
    ///   - resultBuffer: The buffer to store the result.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        textureOne: MTLTexture,
        textureTwo: MTLTexture,
        resultBuffer: MTLBuffer,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Euclidean Distance"
            self.encode(
                textureOne: textureOne,
                textureTwo: textureTwo,
                resultBuffer: resultBuffer,
                using: encoder
            )
        }
    }

    /// Encodes the Euclidean distance computation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - textureOne: The first input texture.
    ///   - textureTwo: The second input texture.
    ///   - resultBuffer: The buffer to store the result.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        textureOne: MTLTexture,
        textureTwo: MTLTexture,
        resultBuffer: MTLBuffer,
        using encoder: MTLComputeCommandEncoder
    ) {
        let threadgroupSize = MTLSize(width: 8, height: 8, depth: 1).clamped(to: textureOne.size)
        let blockSizeWidth = (textureOne.width + threadgroupSize.width - 1) / threadgroupSize.width
        let blockSizeHeight = (textureOne.height + threadgroupSize.height - 1) / threadgroupSize.height
        let blockSize = SIMD2<UInt16>(
            x: .init(blockSizeWidth),
            y: .init(blockSizeHeight)
        )

        encoder.setTextures(textureOne, textureTwo)
        encoder.setValue(blockSize, at: 0)
        encoder.setBuffer(
            resultBuffer,
            offset: 0,
            index: 1
        )

        let threadgroupMemoryLength = threadgroupSize.width * threadgroupSize.height * MemoryLayout<Float>.stride

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


    /// The name of the Metal kernel function used for Euclidean distance calculation.
    public static let functionName = "euclideanDistance"
}
