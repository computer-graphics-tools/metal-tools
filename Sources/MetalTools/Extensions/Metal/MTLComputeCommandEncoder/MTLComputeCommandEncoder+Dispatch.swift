import Metal

public extension MTLComputeCommandEncoder {
    /// Dispatches a 1D compute grid, covering at least the specified size.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The total number of threads to dispatch.
    ///   - threadgroupWidth: The width of each threadgroup (default is the pipeline's thread execution width).
    func dispatch1d(
        state: MTLComputePipelineState,
        covering size: Int,
        threadgroupWidth: Int? = nil
    ) {
        let tgWidth = threadgroupWidth ?? state.threadExecutionWidth
        let tgSize = MTLSize(width: tgWidth, height: 1, depth: 1)

        let count = MTLSize(
            width: (size + tgWidth - 1) / tgWidth,
            height: 1,
            depth: 1
        )

        self.setComputePipelineState(state)
        self.dispatchThreadgroups(count, threadsPerThreadgroup: tgSize)
    }

    /// Dispatches a 1D compute grid with exactly the specified size.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The exact number of threads to dispatch.
    ///   - threadgroupWidth: The width of each threadgroup (default is the pipeline's thread execution width).
    func dispatch1d(
        state: MTLComputePipelineState,
        exactly size: Int,
        threadgroupWidth: Int? = nil
    ) {
        let tgSize = MTLSize(
            width: threadgroupWidth ?? state.threadExecutionWidth,
            height: 1,
            depth: 1
        )

        self.setComputePipelineState(state)
        self.dispatchThreads(
            MTLSize(width: size, height: 1, depth: 1),
            threadsPerThreadgroup: tgSize
        )
    }

    /// Dispatches a 1D compute grid, using the most efficient method available on the device.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The number of threads to dispatch.
    ///   - threadgroupWidth: The width of each threadgroup (default is the pipeline's thread execution width).
    func dispatch1d(
        state: MTLComputePipelineState,
        exactlyOrCovering size: Int,
        threadgroupWidth: Int? = nil
    ) {
        if state.device.supports(feature: .nonUniformThreadgroups) {
            self.dispatch1d(
                state: state,
                exactly: size,
                threadgroupWidth: threadgroupWidth
            )
        } else {
            self.dispatch1d(
                state: state,
                covering: size,
                threadgroupWidth: threadgroupWidth
            )
        }
    }

    /// Dispatches a 2D compute grid, covering at least the specified size.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The total size of the grid to dispatch.
    ///   - threadgroupSize: The size of each threadgroup (default is the pipeline's max 2D threadgroup size).
    func dispatch2d(
        state: MTLComputePipelineState,
        covering size: MTLSize,
        threadgroupSize: MTLSize? = nil
    ) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize

        let count = MTLSize(
            width: (size.width + tgSize.width - 1) / tgSize.width,
            height: (size.height + tgSize.height - 1) / tgSize.height,
            depth: 1
        )

        self.setComputePipelineState(state)
        self.dispatchThreadgroups(count, threadsPerThreadgroup: tgSize)
    }

    /// Dispatches a 2D compute grid with exactly the specified size.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The exact size of the grid to dispatch.
    ///   - threadgroupSize: The size of each threadgroup (default is the pipeline's max 2D threadgroup size).
    func dispatch2d(
        state: MTLComputePipelineState,
        exactly size: MTLSize,
        threadgroupSize: MTLSize? = nil
    ) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize

        self.setComputePipelineState(state)
        self.dispatchThreads(size, threadsPerThreadgroup: tgSize)
    }

    /// Dispatches a 2D compute grid, using the most efficient method available on the device.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The size of the grid to dispatch.
    ///   - threadgroupSize: The size of each threadgroup (default is the pipeline's max 2D threadgroup size).
    func dispatch2d(
        state: MTLComputePipelineState,
        exactlyOrCovering size: MTLSize,
        threadgroupSize: MTLSize? = nil
    ) {
        if state.device.supports(feature: .nonUniformThreadgroups) {
            self.dispatch2d(
                state: state,
                exactly: size,
                threadgroupSize: threadgroupSize
            )
        } else {
            self.dispatch2d(
                state: state,
                covering: size,
                threadgroupSize: threadgroupSize
            )
        }
    }

    /// Dispatches a 3D compute grid, covering at least the specified size.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The total size of the grid to dispatch.
    ///   - threadgroupSize: The size of each threadgroup (default is the pipeline's max 2D threadgroup size).
    func dispatch3d(
        state: MTLComputePipelineState,
        covering size: MTLSize,
        threadgroupSize: MTLSize? = nil
    ) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize

        let count = MTLSize(
            width: (size.width + tgSize.width - 1) / tgSize.width,
            height: (size.height + tgSize.height - 1) / tgSize.height,
            depth: (size.depth + tgSize.depth - 1) / tgSize.depth
        )

        self.setComputePipelineState(state)
        self.dispatchThreadgroups(count, threadsPerThreadgroup: tgSize)
    }

    /// Dispatches a 3D compute grid with exactly the specified size.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The exact size of the grid to dispatch.
    ///   - threadgroupSize: The size of each threadgroup (default is the pipeline's max 2D threadgroup size).
    func dispatch3d(
        state: MTLComputePipelineState,
        exactly size: MTLSize,
        threadgroupSize: MTLSize? = nil
    ) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize

        self.setComputePipelineState(state)
        self.dispatchThreads(size, threadsPerThreadgroup: tgSize)
    }

    /// Dispatches a 3D compute grid, using the most efficient method available on the device.
    ///
    /// - Parameters:
    ///   - state: The compute pipeline state to use.
    ///   - size: The size of the grid to dispatch.
    ///   - threadgroupSize: The size of each threadgroup (default is the pipeline's max 2D threadgroup size).
    func dispatch3d(
        state: MTLComputePipelineState,
        exactlyOrCovering size: MTLSize,
        threadgroupSize: MTLSize? = nil
    ) {
        if state.device.supports(feature: .nonUniformThreadgroups) {
            self.dispatch3d(
                state: state,
                exactly: size,
                threadgroupSize: threadgroupSize
            )
        } else {
            self.dispatch3d(
                state: state,
                covering: size,
                threadgroupSize: threadgroupSize
            )
        }
    }
}
