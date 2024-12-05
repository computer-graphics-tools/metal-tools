import Metal

/// Extension to make `MTLOrigin` conform to the `Equatable` protocol.
extension MTLOrigin: @retroactive Equatable {
    /// Compares two `MTLOrigin` instances for equality.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `MTLOrigin` to compare.
    ///   - rhs: The right-hand side `MTLOrigin` to compare.
    /// - Returns: `true` if the two `MTLOrigin` instances have equal x, y, and z components; otherwise, `false`.
    public static func ==(lhs: MTLOrigin, rhs: MTLOrigin) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
