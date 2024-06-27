/// A collection of errors related to Metal operations.
public enum MetalError {

    /// Errors related to `MTLContext`.
    public enum MTLContextError: Error {
        /// The error for a failed texture cache creation.
        case textureCacheCreationFailed
    }

    /// Errors related to `MTLDevice`.
    public enum MTLDeviceError: Error {
        /// The error for a failed argument encoder creation.
        case argumentEncoderCreationFailed
        /// The error for a failed buffer creation.
        case bufferCreationFailed
        /// The error for a failed command queue creation.
        case commandQueueCreationFailed
        /// The error for a failed depth stencil state creation.
        case depthStencilStateCreationFailed
        /// The error for a failed event creation.
        case eventCreationFailed
        /// The error for a failed fence creation.
        case fenceCreationFailed
        /// The error for a failed heap creation.
        case heapCreationFailed
        /// The error for a failed indirect command buffer creation.
        case indirectCommandBufferCreationFailed
        /// The error for a failed library creation.
        case libraryCreationFailed
        /// The error for a failed rasterization rate map creation.
        case rasterizationRateMapCreationFailed
        /// The error for a failed sampler state creation.
        case samplerStateCreationFailed
        /// The error for a failed texture creation.
        case textureCreationFailed
        /// The error for a failed texture view creation.
        case textureViewCreationFailed
    }

    /// Errors related to `MTLHeap`.
    public enum MTLHeapError: Error {
        /// The error for a failed buffer creation.
        case bufferCreationFailed
        /// The error for a failed texture creation.
        case textureCreationFailed
    }

    /// Errors related to `MTLCommandBuffer`.
    public enum MTLCommandBufferError: Error {
        /// The error for a failed command buffer execution.
        case commandBufferExecutionFailed
    }

    /// Errors related to `MTLCommandQueue`.
    public enum MTLCommandQueueError: Error {
        /// The error for a failed command buffer creation.
        case commandBufferCreationFailed
    }

    /// Errors related to `MTLLibrary`.
    public enum MTLLibraryError: Error {
        /// The error for a failed function retrieval.
        case functionCreationFailed
    }
    
    /// Errors related to `MTLTexture` serialization.
    public enum MTLTextureSerializationError: Error {
        case allocationFailed
        case dataAccessFailure
        case unsupportedPixelFormat
    }
    
    /// Errors related to `MTLTexture`.
    public enum MTLTextureError: Error {
        case imageCreationFailed
        case imageIncompatiblePixelFormat
    }
    
    /// Errors related to `MTLResource`.
    public enum MTLResourceError: Error {
        case resourceUnavailable
    }
    
    /// Errors related to `MTLBuffer`.
    public enum MTLBufferError: Error {
        case incompatibleData
        case textureCreationFailed
    }
    
    /// Errors related to `MTLPixelFormat`.
    public enum MTLPixelFormatError: Error {
        case incompatibleCVPixelFormat
    }
}
