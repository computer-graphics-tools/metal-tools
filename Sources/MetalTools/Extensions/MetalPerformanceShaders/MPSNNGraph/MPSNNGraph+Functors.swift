import MetalPerformanceShaders

public extension MPSNNGraph {
    func callAsFunction(inputs: [MPSImage],
                        in commandBuffer: MTLCommandBuffer) -> MPSImage? {
        return self.encode(to: commandBuffer,
                           sourceImages: inputs)
    }
}
