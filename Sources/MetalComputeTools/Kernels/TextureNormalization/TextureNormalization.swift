import MetalTools

/// A class for performing texture normalization using Metal.
final public class TextureNormalization {
    // MARK: - Properties

    /// The TextureMax instance used for finding the maximum value in the texture.
    private let textureMax: TextureMax

    /// The TextureDivideByConstant instance used for dividing the texture by a constant.
    private let textureDivide: TextureDivideByConstant

    /// The buffer used to store intermediate values.
    private let intermediateBuffer: MTLBuffer

    // MARK: - Life Cycle

    /// Creates a new instance of `TextureNormalization`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the normalization operation with the specified context.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Creates a new instance of `TextureNormalization` with the specified library.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the normalization operation.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the necessary components for the normalization operation.
    public init(library: MTLLibrary) throws {
        self.textureDivide = try .init(library: library)
        self.textureMax = try .init(library: library)
        self.intermediateBuffer = try library.device.buffer(
            for: SIMD4<Float>.self,
            options: .storageModePrivate
        )
    }

    // MARK: - Encode

    /// Encodes the texture normalization operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the normalization operation using the provided textures and command buffer.
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

    /// Encodes the texture normalization operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the normalization operation using the provided textures and command encoder.
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

    /// Encodes the texture normalization operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the normalization operation using the provided textures and command buffer.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Normalization"
            self.encode(
                source: source,
                destination: destination,
                using: encoder
            )
        }
    }

    /// Encodes the texture normalization operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the normalization operation using the provided textures and command encoder.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.textureMax(
            source: source,
            result: self.intermediateBuffer,
            using: encoder
        )
        self.textureDivide(
            source: source,
            destination: destination,
            constant: self.intermediateBuffer,
            using: encoder
        )
    }
}
