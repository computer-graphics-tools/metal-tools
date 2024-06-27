import Metal

public extension MTLRenderCommandEncoder {
    /// Sets a single value as vertex bytes in the render pipeline.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - index: The index of the buffer in the render pipeline state.
    func set<T>(vertexValue value: T, at index: Int) {
        withUnsafePointer(to: value) {
            self.setVertexBytes(
                $0,
                length: MemoryLayout<T>.stride,
                index: index
            )
        }
    }

    /// Sets a collection of values as vertex bytes in the render pipeline.
    ///
    /// - Parameters:
    ///   - value: The collection of values to set.
    ///   - index: The index of the buffer in the render pipeline state.
    func set<T>(vertexValue value: T, at index: Int) where T: Collection {
        withUnsafePointer(to: value) {
            self.setVertexBytes(
                $0,
                length: MemoryLayout<T>.stride * value.count,
                index: index
            )
        }
    }

    /// Sets a single value as fragment bytes in the render pipeline.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - index: The index of the buffer in the render pipeline state.
    func set<T>(fragmentValue value: T, at index: Int) {
        withUnsafePointer(to: value) {
            self.setFragmentBytes(
                $0,
                length: MemoryLayout<T>.stride,
                index: index
            )
        }
    }

    /// Sets a collection of values as fragment bytes in the render pipeline.
    ///
    /// - Parameters:
    ///   - value: The collection of values to set.
    ///   - index: The index of the buffer in the render pipeline state.
    func set<T>(fragmentValue value: T, at index: Int) where T: Collection {
        withUnsafePointer(to: value) {
            self.setFragmentBytes(
                $0,
                length: MemoryLayout<T>.stride * value.count,
                index: index
            )
        }
    }

    /// Sets an array of vertex textures in the render pipeline.
    ///
    /// - Parameters:
    ///   - textures: The array of textures to set.
    ///   - startIndex: The starting index for setting the textures (default is 0).
    func setVertexTextures(_ textures: [MTLTexture?], startingAt startIndex: Int = 0) {
        self.setVertexTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

    /// Sets a variadic list of vertex textures in the render pipeline.
    ///
    /// - Parameters:
    ///   - textures: The variadic list of textures to set.
    ///   - startIndex: The starting index for setting the textures (default is 0).
    func setVertexTextures(_ textures: MTLTexture?..., startingAt startIndex: Int = 0) {
        self.setVertexTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

    /// Sets an array of fragment textures in the render pipeline.
    ///
    /// - Parameters:
    ///   - textures: The array of textures to set.
    ///   - startIndex: The starting index for setting the textures (default is 0).
    func setFragmentTextures(_ textures: [MTLTexture?], startingAt startIndex: Int = 0) {
        self.setFragmentTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

    /// Sets a variadic list of fragment textures in the render pipeline.
    ///
    /// - Parameters:
    ///   - textures: The variadic list of textures to set.
    ///   - startIndex: The starting index for setting the textures (default is 0).
    func setFragmentTextures(_ textures: MTLTexture?..., startingAt startIndex: Int = 0) {
        self.setFragmentTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

    /// Sets an array of vertex buffers in the render pipeline.
    ///
    /// - Parameters:
    ///   - buffers: The array of buffers to set.
    ///   - offsets: The array of offsets for each buffer (default is nil, which sets all offsets to 0).
    ///   - startIndex: The starting index for setting the buffers (default is 0).
    func setVertexBuffers(_ buffers: [MTLBuffer?], offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setVertexBuffers(
            buffers,
            offsets: offsets ?? buffers.map { _ in 0 },
            range: startIndex ..< (startIndex + buffers.count)
        )
    }

    /// Sets a variadic list of vertex buffers in the render pipeline.
    ///
    /// - Parameters:
    ///   - buffers: The variadic list of buffers to set.
    ///   - offsets: The array of offsets for each buffer (default is nil, which sets all offsets to 0).
    ///   - startIndex: The starting index for setting the buffers (default is 0).
    func setVertexBuffers(_ buffers: MTLBuffer?..., offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setVertexBuffers(
            buffers,
            offsets: offsets ?? buffers.map { _ in 0 },
            range: startIndex ..< (startIndex + buffers.count)
        )
    }

    /// Sets an array of fragment buffers in the render pipeline.
    ///
    /// - Parameters:
    ///   - buffers: The array of buffers to set.
    ///   - offsets: The array of offsets for each buffer (default is nil, which sets all offsets to 0).
    ///   - startIndex: The starting index for setting the buffers (default is 0).
    func setFragmentBuffers(_ buffers: [MTLBuffer?], offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setFragmentBuffers(
            buffers,
            offsets: offsets ?? buffers.map { _ in 0 },
            range: startIndex ..< (startIndex + buffers.count)
        )
    }

    /// Sets a variadic list of fragment buffers in the render pipeline.
    ///
    /// - Parameters:
    ///   - buffers: The variadic list of buffers to set.
    ///   - offsets: The array of offsets for each buffer (default is nil, which sets all offsets to 0).
    ///   - startIndex: The starting index for setting the buffers (default is 0).
    func setFragmentBuffers(_ buffers: MTLBuffer?..., offsets: [Int]? = nil, startingAt startIndex: Int = 0) {
        self.setFragmentBuffers(
            buffers,
            offsets: offsets ?? buffers.map { _ in 0 },
            range: startIndex ..< (startIndex + buffers.count)
        )
    }
}
