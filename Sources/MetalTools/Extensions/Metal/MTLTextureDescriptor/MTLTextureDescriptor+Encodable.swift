import Metal

/// Extension to make the MTLTextureDescriptor conform to the Encodable protocol.
extension MTLTextureDescriptor: @retroactive Encodable {

    /// Keys used for encoding the MTLTextureDescriptor properties.
    enum CodingKey: String, Swift.CodingKey {
        case width
        case height
        case depth
        case arrayLength
        case storageMode
        case cpuCacheMode
        case usage
        case textureType
        case sampleCount
        case mipmapLevelCount
        case pixelFormat
        case allowGPUOptimizedContents
    }

    /// Initializes a new MTLTextureDescriptor instance by decoding from the given decoder.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data is corrupted or invalid.
    ///
    /// This initializer decodes the properties of the MTLTextureDescriptor from the provided decoder using the specified coding keys.
    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKey.self)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.depth = try container.decode(Int.self, forKey: .depth)
        self.arrayLength = try container.decode(Int.self, forKey: .arrayLength)
        self.cpuCacheMode = try container.decode(MTLCPUCacheMode.self, forKey: .cpuCacheMode)
        self.usage = try container.decode(MTLTextureUsage.self, forKey: .usage)
        self.textureType = try container.decode(MTLTextureType.self, forKey: .textureType)
        self.sampleCount = try container.decode(Int.self, forKey: .sampleCount)
        self.mipmapLevelCount = try container.decode(Int.self, forKey: .mipmapLevelCount)
        self.pixelFormat = try container.decode(MTLPixelFormat.self, forKey: .pixelFormat)

        if #available(iOS 12, macOS 10.14, *) {
            self.allowGPUOptimizedContents = try container.decodeIfPresent(
                Bool.self,
                forKey: .allowGPUOptimizedContents
            ) ?? true
        }
    }

    /// Encodes the MTLTextureDescriptor instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if encoding to the encoder fails.
    ///
    /// This method encodes the properties of the MTLTextureDescriptor into the provided encoder using the specified coding keys.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)

        try container.encode(self.width, forKey: .width)
        try container.encode(self.height, forKey: .height)
        try container.encode(self.depth, forKey: .depth)
        try container.encode(self.arrayLength, forKey: .arrayLength)
        try container.encode(self.cpuCacheMode, forKey: .cpuCacheMode)
        try container.encode(self.usage, forKey: .usage)
        try container.encode(self.textureType, forKey: .textureType)
        try container.encode(self.sampleCount, forKey: .sampleCount)
        try container.encode(self.mipmapLevelCount, forKey: .mipmapLevelCount)
        try container.encode(self.pixelFormat, forKey: .pixelFormat)

        if #available(iOS 12, macOS 10.14, *) {
            try container.encode(self.allowGPUOptimizedContents, forKey: .allowGPUOptimizedContents)
        }
    }
}
