import Metal

/// Extension to make `MTLOrigin` conform to the `Codable` protocol.
extension MTLOrigin: Codable {
    /// Coding keys for encoding and decoding `MTLOrigin`.
    private enum CodingKey: String, Swift.CodingKey {
        case x, y, z
    }

    /// Initializes an `MTLOrigin` instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: `DecodingError.dataCorruptedError` if the data is corrupted or any value cannot be decoded.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        let x = try container.decode(Int.self, forKey: .x)
        let y = try container.decode(Int.self, forKey: .y)
        let z = try container.decode(Int.self, forKey: .z)

        self.init(x: x, y: y, z: z)
    }

    /// Encodes this `MTLOrigin` instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: `EncodingError.invalidValue` if any value cannot be encoded.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
        try container.encode(self.z, forKey: .z)
    }
}
