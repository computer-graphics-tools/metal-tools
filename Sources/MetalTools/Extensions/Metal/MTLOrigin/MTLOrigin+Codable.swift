import Metal

extension MTLOrigin: Codable {
    private enum CodingKey: String, Swift.CodingKey {
        case x, y, z
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        let x = try container.decode(Int.self, forKey: .x)
        let y = try container.decode(Int.self, forKey: .y)
        let z = try container.decode(Int.self, forKey: .z)

        self.init(x: x, y: y, z: z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
        try container.encode(self.z, forKey: .z)
    }
}
