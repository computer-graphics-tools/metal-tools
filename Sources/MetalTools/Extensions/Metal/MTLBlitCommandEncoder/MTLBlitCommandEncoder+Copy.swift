import Metal

public extension MTLBlitCommandEncoder {
    /// Copies a region from a source texture to a target texture.
    ///
    /// - Parameters:
    ///   - region: The region of the source texture to copy.
    ///   - source: The source texture.
    ///   - targetOrigin: The origin point in the target texture to copy to.
    ///   - target: The target texture.
    ///   - sourceSlice: The source texture slice (default is 0).
    ///   - sourceLevel: The source mipmap level (default is 0).
    ///   - destinationSlice: The destination texture slice (default is 0).
    ///   - destionationLevel: The destination mipmap level (default is 0).
    func copy(
        region: MTLRegion,
        from source: MTLTexture,
        to targetOrigin: MTLOrigin,
        of target: MTLTexture,
        sourceSlice: Int = 0,
        sourceLevel: Int = 0,
        destinationSlice: Int = 0,
        destionationLevel: Int = 0
    ) {
        self.copy(
            from: source,
            sourceSlice: sourceSlice,
            sourceLevel: sourceLevel,
            sourceOrigin: region.origin,
            sourceSize: region.size,
            to: target,
            destinationSlice: destinationSlice,
            destinationLevel: destionationLevel,
            destinationOrigin: targetOrigin
        )
    }

    /// Copies an entire texture to a specified location in a target texture.
    ///
    /// - Parameters:
    ///   - texture: The source texture to copy.
    ///   - targetOrigin: The origin point in the target texture to copy to.
    ///   - target: The target texture.
    ///   - sourceSlice: The source texture slice (default is 0).
    ///   - sourceLevel: The source mipmap level (default is 0).
    ///   - destinationSlice: The destination texture slice (default is 0).
    ///   - destionationLevel: The destination mipmap level (default is 0).
    func copy(
        texture: MTLTexture,
        to targetOrigin: MTLOrigin,
        of target: MTLTexture,
        sourceSlice: Int = 0,
        sourceLevel: Int = 0,
        destinationSlice: Int = 0,
        destionationLevel: Int = 0
    ) {
        let region = texture.region
        self.copy(
            from: texture,
            sourceSlice: sourceSlice,
            sourceLevel: sourceLevel,
            sourceOrigin: region.origin,
            sourceSize: region.size,
            to: target,
            destinationSlice: destinationSlice,
            destinationLevel: destionationLevel,
            destinationOrigin: targetOrigin
        )
    }
}
