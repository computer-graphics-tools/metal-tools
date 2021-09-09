import MetalPerformanceShaders

public extension MPSUnaryImageKernel {
    func callAsFunction(source: MTLTexture,
                        destination: MTLTexture,
                        in commandBuffer: MTLCommandBuffer) {
        self.encode(commandBuffer: commandBuffer,
                    sourceTexture: source,
                    destinationTexture: destination)
    }

    func callAsFunction(inPlace: UnsafeMutablePointer<MTLTexture>,
                        fallbackCopyAllocator: MPSCopyAllocator? = nil,
                        in commandBuffer: MTLCommandBuffer) {
        self.encode(commandBuffer: commandBuffer,
                    inPlaceTexture: inPlace,
                    fallbackCopyAllocator: fallbackCopyAllocator)
    }

}
