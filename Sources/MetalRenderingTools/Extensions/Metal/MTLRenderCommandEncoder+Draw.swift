import MetalTools

public extension MTLRenderCommandEncoder {

    /// Draws indexed primitives using the specified parameters.
    ///
    /// - Parameters:
    ///   - type: The type of primitives to draw.
    ///   - indexBuffer: The index buffer containing the indices to use.
    ///   - instanceCount: The number of instances to draw. Defaults to 1.
    ///
    /// This method draws indexed primitives using the specified parameters, with the index buffer starting at offset 0.
    func drawIndexedPrimitives(
        type: MTLPrimitiveType,
        indexBuffer: MTLIndexBuffer,
        instanceCount: Int = 1
    ) {
        self.drawIndexedPrimitives(
            type: type,
            indexCount: indexBuffer.count,
            indexType: indexBuffer.type,
            indexBuffer: indexBuffer.buffer,
            indexBufferOffset: 0,
            instanceCount: instanceCount
        )
    }

    /// Draws indexed primitives using the specified parameters with a specified offset and count.
    ///
    /// - Parameters:
    ///   - type: The type of primitives to draw.
    ///   - indexBuffer: The index buffer containing the indices to use.
    ///   - offset: The offset within the index buffer to start drawing from.
    ///   - count: The number of indices to draw.
    ///   - instanceCount: The number of instances to draw. Defaults to 1.
    ///
    /// This method draws indexed primitives using the specified parameters, with a specified offset and count.
    /// If the requested index count exceeds the buffer's length in debug mode, it triggers a fatal error.
    func drawIndexedPrimitives(
        type: MTLPrimitiveType,
        indexBuffer: MTLIndexBuffer,
        offset: Int,
        count: Int,
        instanceCount: Int = 1
    ) {
        #if DEBUG
        guard count + offset <= indexBuffer.count
        else { fatalError("Requested index count exceeds provided buffer's length") }
        #endif

        self.drawIndexedPrimitives(
            type: type,
            indexCount: count,
            indexType: indexBuffer.type,
            indexBuffer: indexBuffer.buffer,
            indexBufferOffset: offset,
            instanceCount: instanceCount
        )
    }
}
