import Metal

public extension MTLComputeCommandEncoder {
    
    func dispatch1d(state: MTLComputePipelineState,
                    covering size: Int,
                    threadgroupWidth: Int? = nil) {
        let tgWidth = threadgroupWidth ?? state.threadExecutionWidth
        let tgSize = MTLSize(width: tgWidth, height: 1, depth: 1)
        
        let count = MTLSize(width: (size + tgWidth - 1) / tgWidth,
                            height: 1,
                            depth: 1)
        
        self.setComputePipelineState(state)
        self.dispatchThreadgroups(count, threadsPerThreadgroup: tgSize)
    }
    
    func dispatch1d(state: MTLComputePipelineState,
                    exactly size: Int,
                    threadgroupWidth: Int? = nil) {
        let tgSize = MTLSize(width: threadgroupWidth ?? state.threadExecutionWidth,
                             height: 1,
                             depth: 1)

        self.setComputePipelineState(state)
        self.dispatchThreads(MTLSize(width: size, height: 1, depth: 1),
                             threadsPerThreadgroup: tgSize)
    }
    
    func dispatch1d(state: MTLComputePipelineState,
                    exactlyOrCovering size: Int,
                    threadgroupWidth: Int? = nil) {
        if state.device.supports(feature: .nonUniformThreadgroups) {
            self.dispatch1d(state: state,
                            exactly: size,
                            threadgroupWidth: threadgroupWidth)
        } else {
            self.dispatch1d(state: state,
                            covering: size,
                            threadgroupWidth: threadgroupWidth)
        }
    }
    
    func dispatch2d(state: MTLComputePipelineState,
                    covering size: MTLSize,
                    threadgroupSize: MTLSize? = nil) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize
        
        let count = MTLSize(width: (size.width + tgSize.width - 1) / tgSize.width,
                            height: (size.height + tgSize.height - 1) / tgSize.height,
                            depth: 1)
        
        self.setComputePipelineState(state)
        self.dispatchThreadgroups(count, threadsPerThreadgroup: tgSize)
    }
    
    func dispatch2d(state: MTLComputePipelineState,
                    exactly size: MTLSize,
                    threadgroupSize: MTLSize? = nil) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize
        
        self.setComputePipelineState(state)
        self.dispatchThreads(size, threadsPerThreadgroup: tgSize)
    }
    
    func dispatch2d(state: MTLComputePipelineState,
                    exactlyOrCovering size: MTLSize,
                    threadgroupSize: MTLSize? = nil) {
        if state.device.supports(feature: .nonUniformThreadgroups) {
            self.dispatch2d(state: state,
                            exactly: size,
                            threadgroupSize: threadgroupSize)
        } else {
            self.dispatch2d(state: state,
                            covering: size,
                            threadgroupSize: threadgroupSize)
        }
    }
    
    func dispatch3d(state: MTLComputePipelineState,
                    covering size: MTLSize,
                    threadgroupSize: MTLSize? = nil) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize
        
        let count = MTLSize(width: (size.width + tgSize.width - 1) / tgSize.width,
                            height: (size.height + tgSize.height - 1) / tgSize.height,
                            depth: (size.depth + tgSize.depth - 1) / tgSize.depth)
        
        self.setComputePipelineState(state)
        self.dispatchThreadgroups(count, threadsPerThreadgroup: tgSize)
    }
    
    func dispatch3d(state: MTLComputePipelineState,
                    exactly size: MTLSize,
                    threadgroupSize: MTLSize? = nil) {
        let tgSize = threadgroupSize ?? state.max2dThreadgroupSize
        
        self.setComputePipelineState(state)
        self.dispatchThreads(size, threadsPerThreadgroup: tgSize)
    }
    
    func dispatch3d(state: MTLComputePipelineState,
                    exactlyOrCovering size: MTLSize,
                    threadgroupSize: MTLSize? = nil) {
        if state.device.supports(feature: .nonUniformThreadgroups) {
            self.dispatch3d(state: state,
                            exactly: size,
                            threadgroupSize: threadgroupSize)
        } else {
            self.dispatch3d(state: state,
                            covering: size,
                            threadgroupSize: threadgroupSize)
        }
    }
    
}
