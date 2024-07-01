import Metal

/// A container class that allows encoding and decoding of Metal textures.
public class MTLTextureCodableContainer: Codable {
    /// Errors that can occur during the initialization or texture creation process.
    public enum Error: Swift.Error {
        /// Indicates that the base address for the texture data is missing.
        case missingBaseAddress
    }

    private let descriptor: MTLTextureDescriptorCodableContainer
    private var data: Data

    /// Initializes a new `MTLTextureCodableContainer` from an existing Metal texture.
    ///
    /// This initializer copies the texture data and descriptor into the container.
    ///
    /// - Parameter texture: The Metal texture to encode.
    /// - Throws: An error if the texture data cannot be accessed or copied.
    public init(texture: MTLTexture) throws {
        let descriptor = texture.descriptor
        self.descriptor = .init(descriptor: descriptor)

        let sizeAndAlign = texture.device.heapTextureSizeAndAlign(descriptor: descriptor)

        var data = Data(count: sizeAndAlign.size)
        try data.withUnsafeMutableBytes {
            guard let pointer = $0.baseAddress
            else { throw Error.missingBaseAddress }

            guard let pixelFormatSize = texture.pixelFormat.bytesPerPixel
            else { throw MetalError.MTLTextureSerializationError.unsupportedPixelFormat }

            var offset = 0

            for slice in 0 ..< texture.arrayLength {
                for mipMaplevel in 0 ..< texture.mipmapLevelCount {
                    guard let textureView = texture.makeTextureView(
                        pixelFormat: texture.pixelFormat,
                        textureType: texture.textureType,
                        levels: mipMaplevel ..< mipMaplevel + 1,
                        slices: slice ..< slice + 1
                    )
                    else { throw MetalError.MTLTextureSerializationError.dataAccessFailure }

                    var bytesPerRow = pixelFormatSize * textureView.width
                    let bytesPerImage = bytesPerRow * textureView.height

                    // This comes from docs
                    // > When you copy pixels from a MTLTextureType1D or MTLTextureType1DArray texture, use 0.
                    if texture.textureType == .type1D || texture.textureType == .type1DArray {
                        bytesPerRow = 0
                    }

                    textureView.getBytes(
                        pointer.advanced(by: offset),
                        bytesPerRow: bytesPerRow,
                        bytesPerImage: bytesPerImage,
                        from: textureView.region,
                        mipmapLevel: 0,
                        slice: 0
                    )

                    offset += bytesPerImage
                }
            }
        }

        self.data = data
    }

    /// Creates a new Metal texture from the encoded data in this container.
    ///
    /// - Parameter device: The Metal device to use for creating the texture.
    /// - Returns: A new `MTLTexture` instance.
    /// - Throws: An error if the texture cannot be created or if the data cannot be copied.
    public func texture(device: MTLDevice) throws -> MTLTexture {
        guard let texture = device.makeTexture(descriptor: self.descriptor.descriptor)
        else { throw MetalError.MTLTextureSerializationError.allocationFailed }

        try self.data.withUnsafeMutableBytes {
            guard let pointer = $0.baseAddress
            else { throw Error.missingBaseAddress }

            guard let pixelFormatSize = texture.pixelFormat.bytesPerPixel
            else { throw MetalError.MTLTextureSerializationError.unsupportedPixelFormat }

            var offset = 0

            for slice in 0 ..< texture.arrayLength {
                for mipMaplevel in 0 ..< texture.mipmapLevelCount {
                    guard let textureView = texture.makeTextureView(
                        pixelFormat: texture.pixelFormat,
                        textureType: texture.textureType,
                        levels: mipMaplevel ..< mipMaplevel + 1,
                        slices: slice ..< slice + 1
                    )
                    else { throw MetalError.MTLTextureSerializationError.dataAccessFailure }

                    var bytesPerRow = pixelFormatSize * textureView.width
                    let bytesPerImage = bytesPerRow * textureView.height

                    // This comes from docs
                    // > When you copy pixels from a MTLTextureType1D or MTLTextureType1DArray texture, use 0.
                    if texture.textureType == .type1D || texture.textureType == .type1DArray {
                        bytesPerRow = 0
                    }

                    textureView.replace(
                        region: textureView.region,
                        mipmapLevel: 0,
                        slice: 0,
                        withBytes: pointer.advanced(by: offset),
                        bytesPerRow: bytesPerRow,
                        bytesPerImage: bytesPerImage
                    )

                    offset += bytesPerImage
                }
            }
        }

        return texture
    }
}
