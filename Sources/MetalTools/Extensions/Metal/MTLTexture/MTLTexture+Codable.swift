import Metal

public extension MTLTexture {
    func codable() throws -> MTLTextureCodableContainer {
        try .init(texture: self)
    }
}

