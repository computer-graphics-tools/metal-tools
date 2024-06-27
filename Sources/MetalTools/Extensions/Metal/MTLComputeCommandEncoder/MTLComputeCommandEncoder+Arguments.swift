import Metal

public extension MTLComputeCommandEncoder {
    /// Sets a single value of any type as bytes in the compute function arguments.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - index: The index of the argument in the compute function.
    func setValue<T>(
        _ value: T,
        at index: Int
    ) {
        withUnsafePointer(to: value) {
            self.setBytes(
                $0,
                length: MemoryLayout<T>.stride,
                index: index
            )
        }
    }

    /// Sets an array of values of any type as bytes in the compute function arguments.
    ///
    /// - Parameters:
    ///   - value: The array of values to set.
    ///   - index: The index of the argument in the compute function.
    func setValue<T>(
        _ value: [T],
        at index: Int
    ) {
        value.withUnsafeBufferPointer {
            if let p = $0.baseAddress {
                self.setBytes(
                    p,
                    length: MemoryLayout<T>.stride * value.count,
                    index: index
                )
            }
        }
    }

    /// Sets an array of textures in the compute function arguments.
    ///
    /// - Parameters:
    ///   - textures: The array of textures to set.
    ///   - startIndex: The starting index for setting the textures (default is 0).
    func setTextures(
        _ textures: [MTLTexture?],
        startingAt startIndex: Int = 0
    ) {
        self.setTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

    /// Sets an array of buffers in the compute function arguments.
    ///
    /// - Parameters:
    ///   - buffers: The array of buffers to set.
    ///   - offsets: The array of offsets for each buffer (default is nil, which sets all offsets to 0).
    ///   - startIndex: The starting index for setting the buffers (default is 0).
    func setBuffers(
        _ buffers: [MTLBuffer?],
        offsets: [Int]? = nil,
        startingAt startIndex: Int = 0
    ) {
        self.setBuffers(
            buffers,
            offsets: offsets ?? buffers.map { _ in 0 },
            range: startIndex ..< (startIndex + buffers.count)
        )
    }

    /// Sets a variadic list of textures in the compute function arguments.
    ///
    /// - Parameters:
    ///   - textures: The variadic list of textures to set.
    ///   - startIndex: The starting index for setting the textures (default is 0).
    func setTextures(
        _ textures: MTLTexture?...,
        startingAt startIndex: Int = 0
    ) {
        self.setTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

    /// Sets a variadic list of buffers in the compute function arguments.
    ///
    /// - Parameters:
    ///   - buffers: The variadic list of buffers to set.
    ///   - offsets: The array of offsets for each buffer (default is nil, which sets all offsets to 0).
    ///   - startIndex: The starting index for setting the buffers (default is 0).
    func setBuffers(
        _ buffers: MTLBuffer?...,
        offsets: [Int]? = nil,
        startingAt startIndex: Int = 0
    ) {
        self.setBuffers(
            buffers,
            offsets: offsets ?? buffers.map { _ in 0 },
            range: startIndex ..< (startIndex + buffers.count)
        )
    }
}
