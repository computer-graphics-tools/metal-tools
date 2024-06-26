import Metal

public extension MTLContext {

    // MARK: - MetalTools API

    func scheduleAndWait<T>(_ bufferEncodings: (MTLCommandBuffer) throws -> T) throws -> T {
        try self.commandQueue.scheduleAndWait(bufferEncodings)
    }

    func schedule(_ bufferEncodings: (MTLCommandBuffer) throws -> Void) throws {
        try self.commandQueue.schedule(bufferEncodings)
    }

    func scheduleAsync<T>(_ bufferEncodings: @escaping (MTLCommandBuffer) async throws -> T) async throws -> T {
        try await self.commandQueue.scheduleAsync(bufferEncodings)
    }

    // MARK: - Vanilla API

    var commandQueueLabel: String? {
        get { self.commandQueue.label }
        set { self.commandQueue.label = newValue }
    }

    func commandBuffer() throws -> MTLCommandBuffer {
        try self.commandQueue.commandBuffer()
    }

    func commandBufferWithUnretainedReferences() throws -> MTLCommandBuffer {
        try self.commandQueue.commandBufferWithUnretainedReferences()
    }
}
