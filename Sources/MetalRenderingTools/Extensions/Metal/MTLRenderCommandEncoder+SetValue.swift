import MetalTools

public extension MTLRenderCommandEncoder {
    
    func set<T>(vertexValue value: T, at index: Int) {
        var t = value
        self.setVertexBytes(&t, length: MemoryLayout<T>.stride, index: index)
    }
    
    func set<T>(vertexValue value: T, at index: Int) where T: Collection {
        var t = value
        self.setVertexBytes(&t, length: MemoryLayout<T>.stride * value.count, index: index)
    }
    
    func set<T>(fragmentValue value: T, at index: Int) {
        var t = value
        self.setFragmentBytes(&t, length: MemoryLayout<T>.stride, index: index)
    }
    
    func set<T>(fragmentValue value: T, at index: Int) where T: Collection {
        var t = value
        self.setFragmentBytes(&t, length: MemoryLayout<T>.stride * value.count, index: index)
    }
    
    func set(vertexTextures textures: [MTLTexture?], startingAt startIndex: Int = 0) {
        self.setVertexTextures(textures, range: startIndex..<(startIndex + textures.count))
    }
    
    func set(fragmentTextures textures: [MTLTexture?], startingAt startIndex: Int = 0) {
        self.setFragmentTextures(textures, range: startIndex..<(startIndex + textures.count))
    }
    
    func set(vertexBuffers buffers: [MTLBuffer?], offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setVertexBuffers(buffers,
                              offsets: offsets ?? buffers.map { _ in 0 },
                              range: startIndex..<(startIndex + buffers.count))
    }
    
    func set(fragmentBuffers buffers: [MTLBuffer?], offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setFragmentBuffers(buffers,
                                offsets: offsets ?? buffers.map { _ in 0 },
                                range: startIndex..<(startIndex + buffers.count))
    }

}
