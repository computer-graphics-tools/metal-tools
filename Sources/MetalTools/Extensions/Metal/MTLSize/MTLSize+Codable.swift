import Metal

/// Extension to make the MTLSize structure conform to the Codable protocol.
extension MTLSize: Codable {

    /// Enumeration to define the keys used for encoding and decoding the MTLSize properties.
    private enum CodingKey: String, Swift.CodingKey {
        case width, height, depth
    }

    /// Initializes a new MTLSize instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data is corrupted or invalid.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        let width = try container.decode(Int.self, forKey: .width)
        let height = try container.decode(Int.self, forKey: .height)
        let depth = try container.decode(Int.self, forKey: .depth)

        self.init(width: width, height: height, depth: depth)
    }

    /// Encodes the MTLSize instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if encoding to the encoder fails.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.depth, forKey: .depth)
    }
}
