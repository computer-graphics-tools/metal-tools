import MetalPerformanceShaders

public extension MPSUnaryImageKernel {

    /// Encodes the kernel to a command buffer, applying it to the source texture and writing the result to the destination texture.
    ///
    /// - Parameters:
    ///   - source: The source MTLTexture to be processed by the kernel.
    ///   - destination: The destination MTLTexture to store the result.
    ///   - commandBuffer: The MTLCommandBuffer to encode the kernel to.
    ///
    /// This method allows the MPSUnaryImageKernel to be called as a function, encoding it to the provided command buffer
    /// with the given source and destination textures.
    func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            commandBuffer: commandBuffer,
            sourceTexture: source,
            destinationTexture: destination
        )
    }

    /// Encodes the kernel to a command buffer, applying it to the texture in place.
    ///
    /// - Parameters:
    ///   - inPlace: A pointer to the MTLTexture to be processed in place.
    ///   - fallbackCopyAllocator: Optional. A MPSCopyAllocator to use if in-place processing is not possible. Defaults to nil.
    ///   - commandBuffer: The MTLCommandBuffer to encode the kernel to.
    ///
    /// This method allows the MPSUnaryImageKernel to be called as a function, encoding it to the provided command buffer
    /// and applying it to the texture in place. If in-place processing is not possible, the fallback copy allocator is used.
    func callAsFunction(
        inPlace: UnsafeMutablePointer<MTLTexture>,
        fallbackCopyAllocator: MPSCopyAllocator? = nil,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            commandBuffer: commandBuffer,
            inPlaceTexture: inPlace,
            fallbackCopyAllocator: fallbackCopyAllocator
        )
    }
}
