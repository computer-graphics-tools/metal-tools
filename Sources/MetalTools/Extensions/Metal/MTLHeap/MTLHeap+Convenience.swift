import Metal

public extension MTLHeap {
    /// Creates a buffer in the heap for a specific type.
    ///
    /// - Parameters:
    ///   - type: The type of elements the buffer will hold.
    ///   - count: The number of elements (default is 1).
    ///   - options: Resource options for the buffer.
    /// - Returns: A new Metal buffer allocated from the heap.
    /// - Throws: MetalError.MTLDeviceError.bufferCreationFailed if buffer creation fails.
    func buffer<T>(
        for type: T.Type,
        count: Int = 1,
        options: MTLResourceOptions
    ) throws -> MTLBuffer {
        guard let buffer = self.makeBuffer(
            length: MemoryLayout<T>.stride * count,
            options: options
        )
        else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    /// Creates a buffer in the heap and initializes it with a single value.
    ///
    /// - Parameters:
    ///   - value: The value to store in the buffer.
    ///   - options: Resource options for the buffer (default is .cpuCacheModeWriteCombined).
    /// - Returns: A new Metal buffer allocated from the heap and initialized with the value.
    /// - Throws: MetalError.MTLDeviceError.bufferCreationFailed if buffer creation fails,
    ///           or an error if putting the value into the buffer fails.
    func buffer<T>(
        with value: T,
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        let buffer = try self.buffer(
            for: T.self.self,
            options: options
        )
        try buffer.put(value)
        return buffer
    }

    /// Creates a buffer in the heap and initializes it with an array of values.
    ///
    /// - Parameters:
    ///   - values: The array of values to store in the buffer.
    ///   - options: Resource options for the buffer (default is .cpuCacheModeWriteCombined).
    /// - Returns: A new Metal buffer allocated from the heap and initialized with the values.
    /// - Throws: MetalError.MTLDeviceError.bufferCreationFailed if buffer creation fails,
    ///           or an error if putting the values into the buffer fails.
    func buffer<T>(
        with values: [T],
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        let buffer = try self.buffer(
            for: T.self.self,
            count: values.count,
            options: options
        )
        try buffer.put(values)
        return buffer
    }
}
