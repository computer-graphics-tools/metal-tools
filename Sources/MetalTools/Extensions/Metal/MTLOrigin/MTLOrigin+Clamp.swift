import Metal

public extension MTLOrigin {
    /// Returns a new `MTLOrigin` with its components clamped to the bounds of the given `MTLSize`.
    ///
    /// This method ensures that each component of the origin (x, y, z) is within the range [0, size.dimension],
    /// where dimension is width, height, or depth respectively.
    ///
    /// - Parameter size: The `MTLSize` to clamp the origin to.
    /// - Returns: A new `MTLOrigin` with clamped values.
    func clamped(to size: MTLSize) -> MTLOrigin {
        MTLOrigin(
            x: min(max(self.x, 0), size.width),
            y: min(max(self.y, 0), size.height),
            z: min(max(self.z, 0), size.depth)
        )
    }
}
