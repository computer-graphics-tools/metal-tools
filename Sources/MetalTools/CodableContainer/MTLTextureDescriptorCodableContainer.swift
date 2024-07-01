import Metal

/// A container class that makes `MTLTextureDescriptor` conform to the `Codable` protocol.
final class MTLTextureDescriptorCodableContainer: Codable {
    /// The wrapped `MTLTextureDescriptor` instance.
    let descriptor: MTLTextureDescriptor

    /// Initializes a new `MTLTextureDescriptorCodableContainer` with the given texture descriptor.
    ///
    /// - Parameter descriptor: The `MTLTextureDescriptor` to wrap.
    init(descriptor: MTLTextureDescriptor) {
        self.descriptor = descriptor
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails.
    required init(from decoder: Decoder) throws {
        self.descriptor = try MTLTextureDescriptor(from: decoder)
    }

    /// Encodes this instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if writing to the encoder fails.
    func encode(to encoder: Encoder) throws {
        try self.descriptor.encode(to: encoder)
    }
}
