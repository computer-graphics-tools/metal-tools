import Metal

extension MTLRegion: Codable {
    private enum CodingKey: String, Swift.CodingKey {
        case origin, size
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        let origin = try container.decode(MTLOrigin.self, forKey: .origin)
        let size = try container.decode(MTLSize.self, forKey: .size)

        self.init(origin: origin, size: size)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(self.origin, forKey: .origin)
        try container.encode(self.size, forKey: .size)
    }
}
