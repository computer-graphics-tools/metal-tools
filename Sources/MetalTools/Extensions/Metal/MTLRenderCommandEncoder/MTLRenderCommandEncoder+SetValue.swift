import Metal

public extension MTLRenderCommandEncoder {
    
    func setVertexValue<T>(_ value: T, at index: Int) {
        var t = value
        self.setVertexBytes(&t, length: MemoryLayout<T>.stride, index: index)
    }
    
    func setVertexValue<T>(_ value: [T], at index: Int) {
        var t = value
        self.setVertexBytes(&t, length: MemoryLayout<T>.stride * value.count, index: index)
    }
    
    func setFragmentValue<T>(_ value: T, at index: Int) {
        var t = value
        self.setFragmentBytes(&t, length: MemoryLayout<T>.stride, index: index)
    }
    
    func setFragmentValue<T>(_ value: [T], at index: Int) {
        var t = value
        self.setFragmentBytes(&t, length: MemoryLayout<T>.stride * value.count, index: index)
    }
    
    func setVertexTextures(_ textures: [MTLTexture?], startingAt startIndex: Int = 0) {
        self.setVertexTextures(textures, range: startIndex..<(startIndex + textures.count))
    }
    
    func setVertexTextures(_ textures: MTLTexture?..., startingAt startIndex: Int = 0) {
        self.setVertexTextures(textures, range: startIndex..<(startIndex + textures.count))
    }
    
    func setFragmentTextures(_ textures: [MTLTexture?], startingAt startIndex: Int = 0) {
        self.setFragmentTextures(textures, range: startIndex..<(startIndex + textures.count))
    }
    
    func setFragmentTextures(_ textures: MTLTexture?..., startingAt startIndex: Int = 0) {
        self.setFragmentTextures(textures, range: startIndex..<(startIndex + textures.count))
    }
    
    func setVertexBuffers(_ buffers: [MTLBuffer?], offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setVertexBuffers(buffers,
                              offsets: offsets ?? buffers.map { _ in 0 },
                              range: startIndex..<(startIndex + buffers.count))
    }
    
    func setVertexBuffers(_ buffers: MTLBuffer?..., offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setVertexBuffers(buffers,
                              offsets: offsets ?? buffers.map { _ in 0 },
                              range: startIndex..<(startIndex + buffers.count))
    }
    
    func setFragmentBuffers(_ buffers: [MTLBuffer?], offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setFragmentBuffers(buffers,
                                offsets: offsets ?? buffers.map { _ in 0 },
                                range: startIndex..<(startIndex + buffers.count))
    }
    
    func setFragmentBuffers(_ buffers: MTLBuffer?..., offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setFragmentBuffers(buffers,
                                offsets: offsets ?? buffers.map { _ in 0 },
                                range: startIndex..<(startIndex + buffers.count))
    }

}
