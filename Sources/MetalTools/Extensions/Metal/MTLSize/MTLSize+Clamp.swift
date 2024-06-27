import Metal

/// Extension to the MTLSize structure to provide a method for clamping its dimensions.
public extension MTLSize {

    /// Clamps the dimensions (width, height, depth) of the current MTLSize instance to the specified size.
    ///
    /// - Parameter size: The MTLSize instance to clamp to.
    /// - Returns: A new MTLSize instance with each dimension clamped to the range [0, size.dimension].
    ///
    /// This method ensures that the width, height, and depth of the MTLSize instance
    /// are within the valid range defined by the specified size, with a lower bound of 0.
    func clamped(to size: MTLSize) -> MTLSize {
        MTLSize(
            width:  min(max(self.width, 0), size.width),
            height: min(max(self.height, 0), size.height),
            depth:  min(max(self.depth, 0), size.depth)
        )
    }
}
