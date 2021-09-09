import Metal

public extension MTLTexture {
    func codable() throws -> MTLTextureCodableContainer {
        return try .init(texture: self)
    }
}

