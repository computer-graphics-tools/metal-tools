import Metal

public extension MTLComputePipelineState {
    /// Returns a threadgroup size based on the pipeline's thread execution width.
    ///
    /// This size is optimized for 1D compute kernels.
    var executionWidthThreadgroupSize: MTLSize {
        let w = self.threadExecutionWidth

        return MTLSize(width: w, height: 1, depth: 1)
    }

    /// Returns the maximum threadgroup size for a 1D compute kernel.
    ///
    /// This size uses the maximum total threads per threadgroup.
    var max1dThreadgroupSize: MTLSize {
        let w = self.maxTotalThreadsPerThreadgroup

        return MTLSize(width: w, height: 1, depth: 1)
    }

    /// Returns the maximum threadgroup size for a 2D compute kernel.
    ///
    /// This size balances the thread execution width and the maximum total threads per threadgroup.
    var max2dThreadgroupSize: MTLSize {
        let w = self.threadExecutionWidth
        let h = self.maxTotalThreadsPerThreadgroup / w

        return MTLSize(width: w, height: h, depth: 1)
    }

    /// Calculates the maximum threadgroup size for a 3D compute kernel with a specified depth.
    ///
    /// - Parameter depth: The desired depth of the threadgroup.
    /// - Returns: The maximum threadgroup size that can be used for a 3D compute kernel.
    func max3dThreadgroupSize(depth: Int) -> MTLSize {
        let w = self.threadExecutionWidth / depth
        let h = self.maxTotalThreadsPerThreadgroup / w

        return MTLSize(width: w, height: h, depth: depth)
    }
}
