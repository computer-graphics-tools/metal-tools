import Metal

public extension MTLTexture {

    /// Converts the MTLTexture instance into a codable container.
    ///
    /// - Returns: An MTLTextureCodableContainer that contains the codable representation of the texture.
    /// - Throws: An error if the conversion fails.
    ///
    /// This method wraps the MTLTexture instance into an MTLTextureCodableContainer,
    /// which can then be encoded or decoded using Codable.
    func codable() throws -> MTLTextureCodableContainer {
        try MTLTextureCodableContainer(texture: self)
    }
}
