import Metal

/// Extension to make `MTLRegion` conform to the `Codable` protocol.
extension MTLRegion: Codable {
    /// Coding keys for encoding and decoding `MTLRegion`.
    private enum CodingKey: String, Swift.CodingKey {
        case origin, size
    }

    /// Initializes an `MTLRegion` instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError.dataCorruptedError` if the data is corrupted or any value cannot be decoded.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        let origin = try container.decode(MTLOrigin.self, forKey: .origin)
        let size = try container.decode(MTLSize.self, forKey: .size)

        self.init(origin: origin, size: size)
    }

    /// Encodes this `MTLRegion` instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: `EncodingError.invalidValue` if any value cannot be encoded.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(self.origin, forKey: .origin)
        try container.encode(self.size, forKey: .size)
    }
}
