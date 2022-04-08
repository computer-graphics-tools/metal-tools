import Metal

public extension MTLHeap {
    func buffer<T>(for type: T.Type,
                   count: Int = 1,
                   options: MTLResourceOptions) throws -> MTLBuffer {
        guard let buffer = self.makeBuffer(length: MemoryLayout<T>.stride * count,
                                           options: options)
        else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    func buffer<T>(with value: T,
                   options: MTLResourceOptions = .cpuCacheModeWriteCombined) throws -> MTLBuffer {
        let buffer = try self.buffer(for: T.self.self,
                                     options: options)
        try buffer.put(value)
        return buffer
    }

    func buffer<T>(with values: [T],
                   options: MTLResourceOptions = .cpuCacheModeWriteCombined) throws -> MTLBuffer {
        let buffer = try self.buffer(for: T.self.self,
                                     count: values.count,
                                     options: options)
        try buffer.put(values)
        return buffer
    }
}
