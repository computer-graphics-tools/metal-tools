import Metal

final class MTLTextureDescriptorCodableContainer: Codable {
    let descriptor: MTLTextureDescriptor

    init(descriptor: MTLTextureDescriptor) {
        self.descriptor = descriptor
    }

    required init(from decoder: Decoder) throws {
        self.descriptor = try MTLTextureDescriptor(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try self.descriptor.encode(to: encoder)
    }
}
