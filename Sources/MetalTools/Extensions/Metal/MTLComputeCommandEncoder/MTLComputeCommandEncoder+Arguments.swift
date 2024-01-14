import Metal

public extension MTLComputeCommandEncoder {
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

    func setTextures(
        _ textures: [MTLTexture?],
        startingAt startIndex: Int = 0
    ) {
        self.setTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

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

    func setTextures(
        _ textures: MTLTexture?...,
        startingAt startIndex: Int = 0
    ) {
        self.setTextures(
            textures,
            range: startIndex ..< (startIndex + textures.count)
        )
    }

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
