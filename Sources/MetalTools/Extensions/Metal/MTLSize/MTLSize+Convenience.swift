import Metal

/// Extension to the MTLSize structure to provide convenience initializers and properties.
public extension MTLSize {

    /// Initializes a new MTLSize instance with the same value for width, height, and depth.
    ///
    /// - Parameter value: The value to be set for width, height, and depth.
    ///
    /// This initializer is useful for creating a uniform MTLSize instance where all dimensions are equal.
    init(repeating value: Int) {
        self.init(
            width: value,
            height: value,
            depth: value
        )
    }

    /// A static MTLSize instance with all dimensions set to one.
    ///
    /// This property provides a convenient way to create a MTLSize instance where width, height,
    /// and depth are all set to 1.
    static let one = MTLSize(repeating: 1)

    /// A static MTLSize instance with all dimensions set to zero.
    ///
    /// This property provides a convenient way to create a MTLSize instance where width, height,
    /// and depth are all set to 0.
    static let zero = MTLSize(repeating: 0)
}
