import Metal

extension MTLSize: Codable {
    
    private enum CodingKey: String, Swift.CodingKey {
        case width, height, depth
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        let width = try container.decode(Int.self, forKey: .width)
        let height = try container.decode(Int.self, forKey: .height)
        let depth = try container.decode(Int.self, forKey: .depth)

        self.init(width: width, height: height, depth: depth)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.depth, forKey: .depth)
    }
    
}
