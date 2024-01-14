import Metal

public extension MTLCommandBuffer {
    var gpuExecutionTime: CFTimeInterval {
        self.gpuEndTime - self.gpuStartTime
    }

    var kernelExecutionTime: CFTimeInterval {
        self.kernelEndTime - self.kernelStartTime
    }
}
