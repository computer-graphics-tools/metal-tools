import Metal

public extension MTLContext {

    // MARK: - MetalTools API

    /// Schedules command buffer encodings and waits for their completion.
    ///
    /// - Parameter bufferEncodings: A closure that encodes commands into a `MTLCommandBuffer`.
    /// - Returns: The result of the buffer encodings closure.
    /// - Throws: An error if scheduling or waiting fails.
    ///
    /// This method schedules the provided buffer encodings on the command queue and waits for their completion.
    func scheduleAndWait<T>(_ bufferEncodings: (MTLCommandBuffer) throws -> T) throws -> T {
        try self.commandQueue.scheduleAndWait(bufferEncodings)
    }

    /// Schedules command buffer encodings without waiting for their completion.
    ///
    /// - Parameter bufferEncodings: A closure that encodes commands into a `MTLCommandBuffer`.
    /// - Throws: An error if scheduling fails.
    ///
    /// This method schedules the provided buffer encodings on the command queue without waiting for their completion.
    func schedule(_ bufferEncodings: (MTLCommandBuffer) throws -> Void) throws {
        try self.commandQueue.schedule(bufferEncodings)
    }

    /// Schedules asynchronous command buffer encodings and waits for their completion.
    ///
    /// - Parameter bufferEncodings: An asynchronous closure that encodes commands into a `MTLCommandBuffer`.
    /// - Returns: The result of the buffer encodings closure.
    /// - Throws: An error if scheduling or waiting fails.
    ///
    /// This method schedules the provided asynchronous buffer encodings on the command queue and waits for their completion.
    func scheduleAsync<T>(_ bufferEncodings: @escaping (MTLCommandBuffer) async throws -> T) async throws -> T {
        try await self.commandQueue.scheduleAsync(bufferEncodings)
    }

    // MARK: - Vanilla API

    /// The label for the command queue.
    ///
    /// This property allows you to get or set the label of the command queue.
    var commandQueueLabel: String? {
        get { self.commandQueue.label }
        set { self.commandQueue.label = newValue }
    }

    /// Creates a new command buffer from the command queue.
    ///
    /// - Returns: A new `MTLCommandBuffer` instance.
    /// - Throws: An error if creating the command buffer fails.
    ///
    /// This method creates a new command buffer from the command queue.
    func commandBuffer() throws -> MTLCommandBuffer {
        try self.commandQueue.commandBuffer()
    }

    /// Creates a new command buffer with unretained references from the command queue.
    ///
    /// - Returns: A new `MTLCommandBuffer` instance with unretained references.
    /// - Throws: An error if creating the command buffer fails.
    ///
    /// This method creates a new command buffer with unretained references from the command queue.
    func commandBufferWithUnretainedReferences() throws -> MTLCommandBuffer {
        try self.commandQueue.commandBufferWithUnretainedReferences()
    }
}
