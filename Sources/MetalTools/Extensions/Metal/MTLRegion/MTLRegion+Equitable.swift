import Metal

/// Extension to make `MTLRegion` conform to the `Equatable` protocol.
extension MTLRegion: Equatable {
    /// Compares two `MTLRegion` instances for equality.
    ///
    /// Two `MTLRegion` instances are considered equal if they have the same origin and size.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `MTLRegion` to compare.
    ///   - rhs: The right-hand side `MTLRegion` to compare.
    /// - Returns: `true` if the two `MTLRegion` instances are equal; otherwise, `false`.
    public static func ==(lhs: MTLRegion, rhs: MTLRegion) -> Bool {
        lhs.origin == rhs.origin
            && lhs.size == rhs.size
    }
}
