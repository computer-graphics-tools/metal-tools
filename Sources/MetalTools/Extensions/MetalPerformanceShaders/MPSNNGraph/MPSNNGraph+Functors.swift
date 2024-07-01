import MetalPerformanceShaders

public extension MPSNNGraph {

    /// Encodes the graph to a command buffer with the specified input images.
    ///
    /// - Parameters:
    ///   - inputs: An array of MPSImage objects to be used as inputs to the graph.
    ///   - commandBuffer: The MTLCommandBuffer to encode the graph to.
    /// - Returns: An optional MPSImage that represents the output of the graph.
    ///
    /// This method allows the MPSNNGraph to be called as a function, encoding it to the provided command buffer
    /// with the given input images. It returns an optional MPSImage representing the output of the graph.
    func callAsFunction(
        inputs: [MPSImage],
        in commandBuffer: MTLCommandBuffer
    ) -> MPSImage? {
        self.encode(
            to: commandBuffer,
            sourceImages: inputs
        )
    }
}
