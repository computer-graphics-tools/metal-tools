import Metal

@available(macOS 10.15, macCatalyst 13.0, *)
public extension MTLCommandBuffer {

    var gpuExecutionTime: CFTimeInterval {
        return self.gpuEndTime - self.gpuStartTime
    }

    var kernelExecutionTime: CFTimeInterval {
        return self.kernelEndTime - self.kernelStartTime
    }

}
