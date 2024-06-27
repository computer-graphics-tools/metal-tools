import Metal

public extension MTLBuffer {
    /// Copies the contents of this buffer to another buffer.
    ///
    /// - Parameters:
    ///   - other: The destination buffer.
    ///   - offset: The offset in the destination buffer to start copying to (default is 0).
    func copy(
        to other: MTLBuffer,
        offset: Int = 0
    ) {
        memcpy(
            other.contents() + offset,
            self.contents(),
            self.length
        )
    }

    /// Returns a pointer to the buffer's contents as a specific type.
    ///
    /// - Parameter type: The type to interpret the buffer contents as.
    /// - Returns: An unsafe mutable pointer to the buffer contents, or nil if the buffer is not CPU-accessible.
    func pointer<T>(of type: T.Type) -> UnsafeMutablePointer<T>? {
        guard self.isAccessibleOnCPU
        else { return nil }

        #if DEBUG
        guard self.length >= MemoryLayout<T>.stride
        else { fatalError("Buffer length check failed") }
        #endif

        let bindedPointer = self.contents()
            .assumingMemoryBound(to: type)
        return bindedPointer
    }

    /// Creates an unsafe buffer pointer to the buffer's contents as a specific type.
    ///
    /// - Parameters:
    ///   - type: The type to interpret the buffer contents as.
    ///   - count: The number of elements to include in the buffer pointer.
    /// - Returns: An unsafe buffer pointer to the buffer contents, or nil if the buffer is not CPU-accessible.
    func bufferPointer<T>(
        of type: T.Type,
        count: Int
    ) -> UnsafeBufferPointer<T>? {
        guard let startPointer = self.pointer(of: type)
        else { return nil }
        let bufferPointer = UnsafeBufferPointer(
            start: startPointer,
            count: count
        )
        return bufferPointer
    }

    /// Creates an array from the buffer's contents interpreted as a specific type.
    ///
    /// - Parameters:
    ///   - type: The type to interpret the buffer contents as.
    ///   - count: The number of elements to include in the array.
    /// - Returns: An array of the specified type, or nil if the buffer is not CPU-accessible.
    func array<T>(
        of type: T.Type,
        count: Int
    ) -> [T]? {
        guard let bufferPointer = self.bufferPointer(
            of: type,
            count: count
        )
        else { return nil }
        let valueArray = Array(bufferPointer)
        return valueArray
    }

    /// Puts a single value into the buffer at a specified offset.
    ///
    /// - Parameters:
    ///   - value: The value to put in the buffer.
    ///   - offset: The offset in bytes where to put the value (default is 0).
    /// - Throws: `MetalError.MTLBufferError.incompatibleData` if the buffer doesn't have enough space.
    func put<T>(
        _ value: T,
        at offset: Int = 0
    ) throws {
        guard self.length - offset >= MemoryLayout<T>.stride
        else { throw MetalError.MTLBufferError.incompatibleData }
        (self.contents() + offset).assumingMemoryBound(to: T.self).pointee = value
    }

    /// Puts an array of values into the buffer at a specified offset.
    ///
    /// - Parameters:
    ///   - values: The array of values to put in the buffer.
    ///   - offset: The offset in bytes where to start putting the values (default is 0).
    /// - Throws: `MetalError.MTLBufferError.incompatibleData` if the buffer doesn't have enough space or if the data is incompatible.
    func put<T>(
        _ values: [T],
        at offset: Int = 0
    ) throws {
        let dataLength = MemoryLayout<T>.stride * values.count
        guard length - offset >= dataLength
        else { throw MetalError.MTLBufferError.incompatibleData }

        _ = try values.withUnsafeBytes {
            if let p = $0.baseAddress {
                memcpy(
                    contents() + offset,
                    p,
                    dataLength
                )
            } else {
                throw MetalError.MTLBufferError.incompatibleData
            }
        }
    }
}
