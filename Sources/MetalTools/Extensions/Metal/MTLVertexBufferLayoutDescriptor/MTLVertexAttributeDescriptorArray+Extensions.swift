import Metal

/// Extension to add a convenience initializer to the MTLVertexBufferLayoutDescriptor.
extension MTLVertexBufferLayoutDescriptor {

    /// Convenience initializer for MTLVertexBufferLayoutDescriptor.
    ///
    /// - Parameters:
    ///   - stride: The stride, in bytes, between elements in the buffer.
    ///   - stepFunction: The step function that defines how data is stepped through in the buffer. Defaults to `.perVertex`.
    ///   - stepRate: The rate at which data is stepped through. Defaults to 1.
    ///
    /// This initializer simplifies the creation of a `MTLVertexBufferLayoutDescriptor`
    /// by allowing you to set the stride, step function, and step rate in a single call.
    convenience init(
        stride: Int,
        stepFunction: MTLVertexStepFunction = .perVertex,
        stepRate: Int = 1
    ) {
        self.init()
        self.stride = stride
        self.stepFunction = stepFunction
        self.stepRate = stepRate
    }
}
