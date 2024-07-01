import Metal

public extension MTLCommandBuffer {
    /// The total execution time of the command buffer on the GPU.
    ///
    /// This property calculates the difference between the GPU end time and start time,
    /// representing the total time the GPU spent executing the commands in this buffer.
    ///
    /// - Returns: The execution time in seconds as a `CFTimeInterval`.
    var gpuExecutionTime: CFTimeInterval {
        self.gpuEndTime - self.gpuStartTime
    }

    /// The total execution time of kernels within the command buffer.
    ///
    /// This property calculates the difference between the kernel end time and start time,
    /// representing the time spent executing compute or graphics kernels in this buffer.
    ///
    /// - Returns: The kernel execution time in seconds as a `CFTimeInterval`.
    var kernelExecutionTime: CFTimeInterval {
        self.kernelEndTime - self.kernelStartTime
    }
}
