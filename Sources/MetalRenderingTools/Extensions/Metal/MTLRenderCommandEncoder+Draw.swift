import MetalTools

public extension MTLRenderCommandEncoder {

    func drawIndexedPrimitives(type: MTLPrimitiveType,
                               indexBuffer: MTLIndexBuffer,
                               instanceCount: Int = 1) {
        self.drawIndexedPrimitives(type: type,
                                   indexCount: indexBuffer.count,
                                   indexType: indexBuffer.type,
                                   indexBuffer: indexBuffer.buffer,
                                   indexBufferOffset: 0,
                                   instanceCount: instanceCount)
    }

    func drawIndexedPrimitives(type: MTLPrimitiveType,
                               indexBuffer: MTLIndexBuffer,
                               offset: Int,
                               count: Int,
                               instanceCount: Int = 1) {
        #if DEBUG
        guard count + offset <= indexBuffer.count
        else { fatalError("Requested index count exceeds provided buffer's length") }
        #endif

        self.drawIndexedPrimitives(type: type,
                                   indexCount: count,
                                   indexType: indexBuffer.type,
                                   indexBuffer: indexBuffer.buffer,
                                   indexBufferOffset: offset,
                                   instanceCount: instanceCount)
    }

}
