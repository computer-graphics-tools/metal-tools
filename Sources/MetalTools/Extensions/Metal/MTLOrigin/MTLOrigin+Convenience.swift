import Metal

public extension MTLOrigin {
    /// Initializes a new `MTLOrigin` with all components set to the same value.
    ///
    /// - Parameter value: The integer value to set for all components (x, y, and z).
    init(repeating value: Int) {
        self.init(
            x: value,
            y: value,
            z: value
        )
    }

    /// A constant `MTLOrigin` with all components set to zero.
    static let zero = MTLOrigin(repeating: 0)
}
