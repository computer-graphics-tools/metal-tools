import Metal

public extension MTLCommandQueue {
    /// Creates a new command buffer.
    ///
    /// - Throws: `MetalError.MTLCommandQueueError.commandBufferCreationFailed` if the command buffer cannot be created.
    /// - Returns: A new `MTLCommandBuffer`.
    func commandBuffer() throws -> MTLCommandBuffer {
        guard let commandBuffer = self.makeCommandBuffer()
        else { throw MetalError.MTLCommandQueueError.commandBufferCreationFailed }
        return commandBuffer
    }

    /// Creates a new command buffer that doesn't retain references to encoded resources.
    ///
    /// - Throws: `MetalError.MTLCommandQueueError.commandBufferCreationFailed` if the command buffer cannot be created.
    /// - Returns: A new `MTLCommandBuffer` with unretained references.
    func commandBufferWithUnretainedReferences() throws -> MTLCommandBuffer {
        guard let commandBuffer = self.makeCommandBufferWithUnretainedReferences()
        else { throw MetalError.MTLCommandQueueError.commandBufferCreationFailed }
        return commandBuffer
    }

    /// Creates a command buffer, executes the provided closure, commits the buffer, and waits for completion.
    ///
    /// - Parameter bufferEncodings: A closure that takes a `MTLCommandBuffer` and returns a value of type `T`.
    /// - Throws: Rethrows any error from the closure or command buffer creation.
    /// - Returns: The value returned by the `bufferEncodings` closure.
    func scheduleAndWait<T>(_ bufferEncodings: (MTLCommandBuffer) throws -> T) throws -> T {
        let commandBuffer = try self.commandBuffer()

        let retVal = try bufferEncodings(commandBuffer)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return retVal
    }

    /// Creates a command buffer, executes the provided closure, and commits the buffer without waiting.
    ///
    /// - Parameter bufferEncodings: A closure that takes a `MTLCommandBuffer`.
    /// - Throws: Rethrows any error from the closure or command buffer creation.
    func schedule(_ bufferEncodings: (MTLCommandBuffer) throws -> Void) throws {
        let commandBuffer = try self.commandBuffer()
        try bufferEncodings(commandBuffer)
        commandBuffer.commit()
    }

    /// Asynchronously creates a command buffer, executes the provided closure, and commits the buffer.
    ///
    /// - Parameter bufferEncodings: An asynchronous closure that takes a `MTLCommandBuffer` and returns a value of type `T`.
    /// - Throws: Rethrows any error from the closure, command buffer creation, or execution.
    /// - Returns: The value returned by the `bufferEncodings` closure.
    func scheduleAsync<T>(_ bufferEncodings: @escaping (MTLCommandBuffer) async throws -> T) async throws -> T {
        let commandBuffer = try self.commandBuffer()

        let retVal = try await bufferEncodings(commandBuffer)

        return try await withCheckedThrowingContinuation { continuation in
            commandBuffer.addCompletedHandler { buffer in
                if buffer.status == .error {
                    let error = buffer.error ?? MetalError.MTLCommandBufferError.commandBufferExecutionFailed
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: retVal)
                }
            }
            commandBuffer.commit()
        }
    }
}
