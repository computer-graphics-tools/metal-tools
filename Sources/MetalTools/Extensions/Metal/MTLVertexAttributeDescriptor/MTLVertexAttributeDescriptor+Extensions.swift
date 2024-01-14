import Metal

extension MTLVertexAttributeDescriptor {
    convenience init(format: MTLVertexFormat, offset: Int, bufferIndex: Int) {
        self.init()
        self.format = format
        self.offset = offset
        self.bufferIndex = bufferIndex
    }
}
