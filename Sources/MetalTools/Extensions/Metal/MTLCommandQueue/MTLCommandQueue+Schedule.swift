import Metal

public extension MTLCommandQueue {

    func commandBuffer() throws -> MTLCommandBuffer {
        guard let commandBuffer = self.makeCommandBuffer()
        else { throw MetalError.MTLCommandQueueError.commandBufferCreationFailed }
        return commandBuffer
    }

    func commandBufferWithUnretainedReferences() throws -> MTLCommandBuffer {
        guard let commandBuffer = self.makeCommandBufferWithUnretainedReferences()
        else { throw MetalError.MTLCommandQueueError.commandBufferCreationFailed }
        return commandBuffer
    }

    func scheduleAndWait<T>(_ bufferEncodings: (MTLCommandBuffer) throws -> T) throws -> T {
        let commandBuffer = try self.commandBuffer()

        let retVal = try bufferEncodings(commandBuffer)

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return retVal
    }

    func schedule(_ bufferEncodings: (MTLCommandBuffer) throws -> Void) throws {
        let commandBuffer = try self.commandBuffer()
        try bufferEncodings(commandBuffer)
        commandBuffer.commit()
    }

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
