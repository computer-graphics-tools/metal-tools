import Metal

/// Extension to add a convenience initializer to the MTLVertexAttributeDescriptor.
extension MTLVertexAttributeDescriptor {

    /// Convenience initializer for MTLVertexAttributeDescriptor.
    ///
    /// - Parameters:
    ///   - format: The vertex format of the attribute.
    ///   - offset: The byte offset of the attribute from the start of the vertex.
    ///   - bufferIndex: The index of the buffer that contains the attribute.
    ///
    /// This initializer simplifies the creation of a `MTLVertexAttributeDescriptor`
    /// by allowing you to set the format, offset, and buffer index in a single call.
    convenience init(
        format: MTLVertexFormat,
        offset: Int,
        bufferIndex: Int
    ) {
        self.init()
        self.format = format
        self.offset = offset
        self.bufferIndex = bufferIndex
    }
}
