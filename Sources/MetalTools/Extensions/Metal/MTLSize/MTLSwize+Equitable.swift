import Metal

/// Extension to make the MTLSize structure conform to the Equatable protocol.
extension MTLSize: @retroactive Equatable {

    /// Checks if two MTLSize instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side MTLSize instance.
    ///   - rhs: The right-hand side MTLSize instance.
    /// - Returns: A Boolean value indicating whether the two MTLSize instances are equal.
    ///
    /// Two MTLSize instances are considered equal if their width, height, and depth are all equal.
    public static func ==(lhs: MTLSize, rhs: MTLSize) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height && lhs.depth == rhs.depth
    }
}
