import Metal
import CoreGraphics

public extension MTLContext {
    // MARK: - MetalTools API

    /// Returns the maximum texture size that can be created with the desired size.
    ///
    /// - Parameter desiredSize: The desired size for the texture.
    /// - Returns: The maximum `MTLSize` that can be created.
    ///
    /// This method determines the maximum texture size that can be created based on the desired size.
    func maxTextureSize(desiredSize: MTLSize) -> MTLSize {
        self.device.maxTextureSize(desiredSize: desiredSize)
    }

    /// Creates a library from the specified file URL.
    ///
    /// - Parameters:
    ///   - file: The URL of the file containing the Metal library source.
    ///   - options: Optional. The compilation options to use.
    /// - Returns: The compiled `MTLLibrary`.
    /// - Throws: An error if the library creation fails.
    ///
    /// This method compiles a Metal library from the specified file URL with the given compilation options.
    func library(
        from file: URL,
        options: MTLCompileOptions? = nil
    ) throws -> MTLLibrary {
        try self.device.library(
            from: file,
            options: options
        )
    }

    /// Creates a pair of multisample render target textures.
    ///
    /// - Parameters:
    ///   - width: The width of the render targets.
    ///   - height: The height of the render targets.
    ///   - pixelFormat: The pixel format of the render targets.
    ///   - sampleCount: The number of samples for multisampling. Defaults to 4.
    /// - Returns: A tuple containing the main and resolve `MTLTexture` instances.
    /// - Throws: An error if the render target pair creation fails.
    ///
    /// This method creates a pair of multisample render target textures with the specified dimensions, pixel format, and sample count.
    func multisampleRenderTargetPair(
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        sampleCount: Int = 4
    ) throws -> (
        main: MTLTexture,
        resolve: MTLTexture
    ) {
        try self.device.multisampleRenderTargetPair(
            width: width,
            height: height,
            pixelFormat: pixelFormat,
            sampleCount: sampleCount
        )
    }

    /// Creates a texture from the specified Core Graphics image.
    ///
    /// - Parameters:
    ///   - cgImage: The `CGImage` to create the texture from.
    ///   - srgb: Whether the texture should use sRGB format. Defaults to false.
    ///   - usage: The usage options for the texture. Defaults to an empty set.
    /// - Returns: The created `MTLTexture`.
    /// - Throws: An error if the texture creation fails.
    ///
    /// This method creates a `MTLTexture` from the specified `CGImage` with the given usage options and sRGB format setting.
    func texture(
        from cgImage: CGImage,
        srgb: Bool = false,
        usage: MTLTextureUsage = []
    ) throws -> MTLTexture {
        try self.device.texture(
            from: cgImage,
            srgb: srgb,
            usage: usage
        )
    }

    /// Creates a texture with the specified width, height, and pixel format.
    ///
    /// - Parameters:
    ///   - width: The width of the texture.
    ///   - height: The height of the texture.
    ///   - pixelFormat: The pixel format of the texture.
    ///   - options: The resource options for the texture. Defaults to an empty set.
    ///   - usage: The usage options for the texture. Defaults to an empty set.
    /// - Returns: The created `MTLTexture`.
    /// - Throws: An error if the texture creation fails.
    ///
    /// This method creates a `MTLTexture` with the specified width, height, pixel format, resource options, and usage options.
    func texture(
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        options: MTLResourceOptions = [],
        usage: MTLTextureUsage = []
    ) throws -> MTLTexture {
        try self.device.texture(
            width: width,
            height: height,
            pixelFormat: pixelFormat,
            options: options,
            usage: usage
        )
    }

    /// Creates a texture from the specified IOSurface.
    ///
    /// - Parameters:
    ///   - iosurface: The `IOSurfaceRef` to create the texture from.
    ///   - plane: The plane of the IOSurface to use. Defaults to 0.
    ///   - options: The resource options for the texture. Defaults to an empty set.
    ///   - usage: The usage options for the texture. Defaults to an empty set.
    /// - Returns: The created `MTLTexture`.
    /// - Throws: An error if the texture creation fails.
    ///
    /// This method creates a `MTLTexture` from the specified IOSurface with the given plane, resource options, and usage options.
    func texture(
        iosurface: IOSurfaceRef,
        plane: Int = 0,
        options: MTLResourceOptions = [],
        usage: MTLTextureUsage = []
    ) throws -> MTLTexture {
        try self.device.texture(
            iosurface: iosurface,
            plane: plane,
            options: options,
            usage: usage
        )
    }

    /// Creates a depth state object with the specified depth compare function and depth write setting.
    ///
    /// - Parameters:
    ///   - depthCompareFunction: The compare function to use for depth testing.
    ///   - isDepthWriteEnabled: Whether depth writes are enabled. Defaults to true.
    /// - Returns: The created `MTLDepthStencilState` object.
    /// - Throws: An error if the depth state creation fails.
    ///
    /// This method creates a `MTLDepthStencilState` object with the specified depth compare function and depth write setting.
    func depthState(
        depthCompareFunction: MTLCompareFunction,
        isDepthWriteEnabled: Bool = true
    ) throws -> MTLDepthStencilState {
        try self.device.depthState(
            depthCompareFunction: depthCompareFunction,
            isDepthWriteEnabled: isDepthWriteEnabled
        )
    }

    /// Creates a depth buffer with the specified width, height, usage, and storage mode.
    ///
    /// - Parameters:
    ///   - width: The width of the depth buffer.
    ///   - height: The height of the depth buffer.
    ///   - usage: The usage options for the depth buffer. Defaults to an empty set.
    ///   - storageMode: The storage mode for the depth buffer. Optional.
    /// - Returns: The created `MTLTexture` representing the depth buffer.
    /// - Throws: An error if the depth buffer creation fails.
    ///
    /// This method creates a depth buffer with the specified width, height, usage, and storage mode.
    func depthBuffer(
        width: Int,
        height: Int,
        usage: MTLTextureUsage = [],
        storageMode: MTLStorageMode? = nil
    ) throws -> MTLTexture {
        try self.device.depthBuffer(
            width: width,
            height: height,
            usage: usage,
            storageMode: storageMode
        )
    }

    /// Creates a buffer for the specified type and count.
    ///
    /// - Parameters:
    ///   - type: The type of the elements in the buffer.
    ///   - count: The number of elements in the buffer. Defaults to 1.
    ///   - options: The resource options for the buffer. Defaults to `.cpuCacheModeWriteCombined`.
    /// - Returns: The created `MTLBuffer`.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This method creates a buffer for the specified type and count with the given resource options.
    func buffer<T>(
        for type: T.Type,
        count: Int = 1,
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        try self.device.buffer(
            for: type,
            count: count,
            options: options
        )
    }

    /// Creates a buffer with the specified value.
    ///
    /// - Parameters:
    ///   - value: The value to initialize the buffer with.
    ///   - options: The resource options for the buffer. Defaults to `.cpuCacheModeWriteCombined`.
    /// - Returns: The created `MTLBuffer`.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This method creates a buffer initialized with the specified value and resource options.
    func buffer<T>(
        with value: T,
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        try self.device.buffer(
            with: value,
            options: options
        )
    }

    /// Creates a buffer with the specified array of values.
    ///
    /// - Parameters:
    ///   - values: The array of values to initialize the buffer with.
    ///   - options: The resource options for the buffer. Defaults to `.cpuCacheModeWriteCombined`.
    /// - Returns: The created `MTLBuffer`.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This method creates a buffer initialized with the specified array of values and resource options.
    func buffer<T>(
        with values: [T],
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        try self.device.buffer(
            with: values,
            options: options
        )
    }

    /// Creates a heap with the specified size, storage mode, and CPU cache mode.
    ///
    /// - Parameters:
    ///   - size: The size of the heap in bytes.
    ///   - storageMode: The storage mode for the heap.
    ///   - cpuCacheMode: The CPU cache mode for the heap. Defaults to `.defaultCache`.
    /// - Returns: The created `MTLHeap`.
    /// - Throws: An error if the heap creation fails.
    ///
    /// This method creates a `MTLHeap` with the specified size, storage mode, and CPU cache mode.
    func heap(
        size: Int,
        storageMode: MTLStorageMode,
        cpuCacheMode: MTLCPUCacheMode = .defaultCache
    ) throws -> MTLHeap {
        try self.device.heap(
            size: size,
            storageMode: storageMode,
            cpuCacheMode: cpuCacheMode
        )
    }

    // MARK: - Vanilla API

    /// The maximum threadgroup memory length supported by the device.
    ///
    /// This property provides the maximum length, in bytes, of threadgroup memory that the device supports.
    var maxThreadgroupMemoryLength: Int {
        self.device.maxThreadgroupMemoryLength
    }

    /// The maximum number of samplers that can be used in an argument buffer.
    ///
    /// This property provides the maximum number of samplers that the device supports in an argument buffer.
    var maxArgumentBufferSamplerCount: Int {
        self.device.maxArgumentBufferSamplerCount
    }

    /// Indicates whether programmable sample positions are supported by the device.
    ///
    /// This property indicates whether the device supports programmable sample positions.
    var areProgrammableSamplePositionsSupported: Bool {
        self.device.areProgrammableSamplePositionsSupported
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    /// The size of sparse tiles in bytes.
    ///
    /// This property provides the size of sparse tiles in bytes for the device.
    var sparseTileSizeInBytes: Int {
        self.device.sparseTileSizeInBytes
    }
    #endif

    /// The maximum length of buffers supported by the device.
    ///
    /// This property provides the maximum length, in bytes, of buffers that the device supports.
    var maxBufferLength: Int {
        self.device.maxBufferLength
    }

    /// The name of the device.
    ///
    /// This property provides the name of the device.
    var deviceName: String {
        self.device.name
    }

    /// The registry ID of the device.
    ///
    /// This property provides the registry ID of the device.
    var registryID: UInt64 {
        self.device.registryID
    }

    /// The maximum number of threads per threadgroup.
    ///
    /// This property provides the maximum number of threads per threadgroup that the device supports.
    var maxThreadsPerThreadgroup: MTLSize {
        self.device.maxThreadsPerThreadgroup
    }

    /// Indicates whether the device has unified memory.
    ///
    /// This property indicates whether the device has unified memory.
    var hasUnifiedMemory: Bool {
        self.device.hasUnifiedMemory
    }

    /// The read-write texture support tier of the device.
    ///
    /// This property provides the read-write texture support tier of the device.
    var readWriteTextureSupport: MTLReadWriteTextureTier {
        self.device.readWriteTextureSupport
    }

    /// The argument buffers support tier of the device.
    ///
    /// This property provides the argument buffers support tier of the device.
    var argumentBuffersSupport: MTLArgumentBuffersTier {
        self.device.argumentBuffersSupport
    }

    /// Indicates whether raster order groups are supported by the device.
    ///
    /// This property indicates whether the device supports raster order groups.
    var areRasterOrderGroupsSupported: Bool {
        self.device.areRasterOrderGroupsSupported
    }

    /// The current allocated size of resources on the device.
    ///
    /// This property provides the current allocated size, in bytes, of resources on the device.
    var currentAllocatedSize: Int {
        self.device.currentAllocatedSize
    }

    /// Returns the size and alignment requirements for a texture descriptor.
    ///
    /// - Parameter desc: The `MTLTextureDescriptor` to query.
    /// - Returns: The `MTLSizeAndAlign` structure containing the size and alignment requirements.
    ///
    /// This method returns the size and alignment requirements for a texture descriptor.
    func heapTextureSizeAndAlign(descriptor desc: MTLTextureDescriptor) -> MTLSizeAndAlign {
        self.device.heapTextureSizeAndAlign(descriptor: desc)
    }

    /// Returns the size and alignment requirements for a buffer of the given length and resource options.
    ///
    /// - Parameters:
    ///   - length: The length of the buffer.
    ///   - options: The resource options for the buffer. Defaults to an empty set.
    /// - Returns: The `MTLSizeAndAlign` structure containing the size and alignment requirements.
    ///
    /// This method returns the size and alignment requirements for a buffer of the given length and resource options.
    func heapBufferSizeAndAlign(
        length: Int,
        options: MTLResourceOptions = []
    ) -> MTLSizeAndAlign {
        self.device.heapBufferSizeAndAlign(
            length: length,
            options: options
        )
    }

    /// Creates a heap with the specified descriptor.
    ///
    /// - Parameter descriptor: The descriptor for the heap.
    /// - Returns: The created `MTLHeap`.
    /// - Throws: An error if the heap creation fails.
    ///
    /// This method creates a `MTLHeap` with the specified descriptor.
    func heap(descriptor: MTLHeapDescriptor) throws -> MTLHeap {
        guard let heap = self.device.makeHeap(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.heapCreationFailed }
        return heap
    }

    /// Creates a buffer of the specified length and resource options.
    ///
    /// - Parameters:
    ///   - length: The length of the buffer.
    ///   - options: The resource options for the buffer. Defaults to an empty set.
    /// - Returns: The created `MTLBuffer`.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This method creates a `MTLBuffer` of the specified length and resource options.
    func buffer(
        length: Int,
        options: MTLResourceOptions = []
    ) throws -> MTLBuffer {
        guard let buffer = self.device.makeBuffer(
            length: length,
            options: options
        )
        else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    /// Creates a buffer with the specified bytes, length, and resource options.
    ///
    /// - Parameters:
    ///   - pointer: A pointer to the bytes to initialize the buffer with.
    ///   - length: The length of the buffer.
    ///   - options: The resource options for the buffer. Defaults to an empty set.
    /// - Returns: The created `MTLBuffer`.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This method creates a `MTLBuffer` initialized with the specified bytes, length, and resource options.
    func buffer(
        bytes pointer: UnsafeRawPointer,
        length: Int,
        options: MTLResourceOptions = []
    ) throws -> MTLBuffer {
        guard let buffer = self.device.makeBuffer(
            bytes: pointer,
            length: length,
            options: options
        )
        else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    /// Creates a buffer with the specified bytes, length, resource options, and deallocator.
    ///
    /// - Parameters:
    ///   - pointer: A pointer to the bytes to initialize the buffer with.
    ///   - length: The length of the buffer.
    ///   - options: The resource options for the buffer. Defaults to an empty set.
    ///   - deallocator: An optional closure to deallocate the bytes. Defaults to nil.
    /// - Returns: The created `MTLBuffer`.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This method creates a `MTLBuffer` initialized with the specified bytes, length, resource options, and deallocator.
    func buffer(
        bytesNoCopy pointer: UnsafeMutableRawPointer,
        length: Int,
        options: MTLResourceOptions = [],
        deallocator: ((UnsafeMutableRawPointer, Int) -> Void)? = nil
    ) throws -> MTLBuffer {
        guard let buffer = self.device.makeBuffer(
            bytesNoCopy: pointer,
            length: length,
            options: options,
            deallocator: deallocator
        )
        else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    /// Creates a depth stencil state with the specified descriptor.
    ///
    /// - Parameter descriptor: The descriptor for the depth stencil state.
    /// - Returns: The created `MTLDepthStencilState`.
    /// - Throws: An error if the depth stencil state creation fails.
    ///
    /// This method creates a `MTLDepthStencilState` with the specified descriptor.
    func depthStencilState(descriptor: MTLDepthStencilDescriptor) throws -> MTLDepthStencilState {
        guard let state = self.device.makeDepthStencilState(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.depthStencilStateCreationFailed }
        return state
    }

    /// Creates a texture with the specified descriptor.
    ///
    /// - Parameter descriptor: The descriptor for the texture.
    /// - Returns: The created `MTLTexture`.
    /// - Throws: An error if the texture creation fails.
    ///
    /// This method creates a `MTLTexture` with the specified descriptor.
    func texture(descriptor: MTLTextureDescriptor) throws -> MTLTexture {
        guard let texture = self.device.makeTexture(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }

    /// Creates a texture with the specified descriptor, IOSurface, and plane.
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor for the texture.
    ///   - iosurface: The `IOSurfaceRef` to create the texture from.
    ///   - plane: The plane of the IOSurface to use.
    /// - Returns: The created `MTLTexture`.
    /// - Throws: An error if the texture creation fails.
    ///
    /// This method creates a `MTLTexture` with the specified descriptor, IOSurface, and plane.
    func texture(
        descriptor: MTLTextureDescriptor,
        iosurface: IOSurfaceRef,
        plane: Int
    ) throws -> MTLTexture {
        guard let texture = self.device.makeTexture(
            descriptor: descriptor,
            iosurface: iosurface,
            plane: plane
        )
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }

    #if !targetEnvironment(simulator)
    /// Creates a shared texture with the specified descriptor.
    ///
    /// - Parameter descriptor: The descriptor for the shared texture.
    /// - Returns: The created `MTLTexture`.
    /// - Throws: An error if the shared texture creation fails.
    ///
    /// This method creates a shared `MTLTexture` with the specified descriptor.
    func sharedTexture(descriptor: MTLTextureDescriptor) throws -> MTLTexture {
        guard let texture = self.device.makeSharedTexture(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }

    /// Creates a shared texture with the specified shared texture handle.
    ///
    /// - Parameter sharedHandle: The handle for the shared texture.
    /// - Returns: The created `MTLTexture`.
    /// - Throws: An error if the shared texture creation fails.
    ///
    /// This method creates a shared `MTLTexture` with the specified shared texture handle.
    func sharedTexture(handle sharedHandle: MTLSharedTextureHandle) throws -> MTLTexture {
        guard let texture = self.device.makeSharedTexture(handle: sharedHandle)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }
    #endif

    /// Creates a sampler state with the specified descriptor.
    ///
    /// - Parameter descriptor: The descriptor for the sampler state.
    /// - Returns: The created `MTLSamplerState`.
    /// - Throws: An error if the sampler state creation fails.
    ///
    /// This method creates a `MTLSamplerState` with the specified descriptor.
    func samplerState(descriptor: MTLSamplerDescriptor) throws -> MTLSamplerState {
        guard let samplerState = self.device.makeSamplerState(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.samplerStateCreationFailed }
        return samplerState
    }

    /// Creates a library from the specified file path.
    ///
    /// - Parameter filepath: The file path to the library.
    /// - Returns: The created `MTLLibrary`.
    /// - Throws: An error if the library creation fails.
    ///
    /// This method creates a `MTLLibrary` from the specified file path.
    func library(filepath: String) throws -> MTLLibrary {
        try self.device.makeLibrary(filepath: filepath)
    }

    /// Creates a library from the specified URL.
    ///
    /// - Parameter url: The URL to the library.
    /// - Returns: The created `MTLLibrary`.
    /// - Throws: An error if the library creation fails.
    ///
    /// This method creates a `MTLLibrary` from the specified URL.
    func library(URL url: URL) throws -> MTLLibrary {
        try self.device.makeLibrary(URL: url)
    }

    /// Creates a library from the specified data.
    ///
    /// - Parameter data: The data for the library.
    /// - Returns: The created `MTLLibrary`.
    /// - Throws: An error if the library creation fails.
    ///
    /// This method creates a `MTLLibrary` from the specified data.
    func library(data: __DispatchData) throws -> MTLLibrary {
        try self.device.makeLibrary(data: data)
    }

    /// Creates a library from the specified source code and compilation options.
    ///
    /// - Parameters:
    ///   - source: The source code for the library.
    ///   - options: The compilation options for the library. Defaults to nil.
    /// - Returns: The created `MTLLibrary`.
    /// - Throws: An error if the library creation fails.
    ///
    /// This method creates a `MTLLibrary` from the specified source code and compilation options.
    func library(
        source: String,
        options: MTLCompileOptions? = nil
    ) throws -> MTLLibrary {
        try self.device.makeLibrary(
            source: source,
            options: options
        )
    }

    /// Creates a library from the specified source code and compilation options, with a completion handler.
    ///
    /// - Parameters:
    ///   - source: The source code for the library.
    ///   - options: The compilation options for the library. Defaults to nil.
    ///   - completionHandler: A completion handler called when the library is created.
    ///
    /// This method creates a `MTLLibrary` from the specified source code and compilation options, and calls the completion handler when done.
    func library(
        source: String,
        options: MTLCompileOptions? = nil,
        completionHandler: @escaping MTLNewLibraryCompletionHandler
    ) {
        self.device.makeLibrary(
            source: source,
            options: options,
            completionHandler: completionHandler
        )
    }

    /// Creates a render pipeline state with the specified descriptor.
    ///
    /// - Parameter descriptor: The descriptor for the render pipeline state.
    /// - Returns: The created `MTLRenderPipelineState`.
    /// - Throws: An error if the render pipeline state creation fails.
    ///
    /// This method creates a `MTLRenderPipelineState` with the specified descriptor.
    func renderPipelineState(descriptor: MTLRenderPipelineDescriptor) throws -> MTLRenderPipelineState {
        try self.device.makeRenderPipelineState(descriptor: descriptor)
    }

    /// Creates a render pipeline state with the specified descriptor, options, and reflection.
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor for the render pipeline state.
    ///   - options: The pipeline options for the render pipeline state.
    ///   - reflection: An optional reflection object to capture detailed information about the pipeline state. Defaults to nil.
    /// - Returns: The created `MTLRenderPipelineState`.
    /// - Throws: An error if the render pipeline state creation fails.
    ///
    /// This method creates a `MTLRenderPipelineState` with the specified descriptor, options, and reflection.
    func renderPipelineState(
        descriptor: MTLRenderPipelineDescriptor,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedRenderPipelineReflection?>? = nil
    ) throws -> MTLRenderPipelineState {
        try self.device.makeRenderPipelineState(
            descriptor: descriptor,
            options: options,
            reflection: reflection
        )
    }

    /// Creates a render pipeline state with the specified descriptor and completion handler.
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor for the render pipeline state.
    ///   - completionHandler: A completion handler called when the render pipeline state is created.
    ///
    /// This method creates a `MTLRenderPipelineState` with the specified descriptor and calls the completion handler when done.
    func renderPipelineState(
        descriptor: MTLRenderPipelineDescriptor,
        completionHandler: @escaping MTLNewRenderPipelineStateCompletionHandler
    ) {
        self.device.makeRenderPipelineState(
            descriptor: descriptor,
            completionHandler: completionHandler
        )
    }

    /// Creates a render pipeline state with the specified descriptor, options, and completion handler.
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor for the render pipeline state.
    ///   - options: The pipeline options for the render pipeline state.
    ///   - completionHandler: A completion handler called when the render pipeline state is created.
    ///
    /// This method creates a `MTLRenderPipelineState` with the specified descriptor, options, and calls the completion handler when done.
    func renderPipelineState(
        descriptor: MTLRenderPipelineDescriptor,
        options: MTLPipelineOption,
        completionHandler: @escaping MTLNewRenderPipelineStateWithReflectionCompletionHandler
    ) {
        self.device.makeRenderPipelineState(
            descriptor: descriptor,
            options: options,
            completionHandler: completionHandler
        )
    }

    /// Creates a compute pipeline state with the specified function.
    ///
    /// - Parameter computeFunction: The function for the compute pipeline state.
    /// - Returns: The created `MTLComputePipelineState`.
    /// - Throws: An error if the compute pipeline state creation fails.
    ///
    /// This method creates a `MTLComputePipelineState` with the specified function.
    func computePipelineState(function computeFunction: MTLFunction) throws -> MTLComputePipelineState {
        try self.device.makeComputePipelineState(function: computeFunction)
    }

    /// Creates a compute pipeline state with the specified function, options, and reflection.
    ///
    /// - Parameters:
    ///   - computeFunction: The function for the compute pipeline state.
    ///   - options: The pipeline options for the compute pipeline state.
    ///   - reflection: An optional reflection object to capture detailed information about the pipeline state. Defaults to nil.
    /// - Returns: The created `MTLComputePipelineState`.
    /// - Throws: An error if the compute pipeline state creation fails.
    ///
    /// This method creates a `MTLComputePipelineState` with the specified function, options, and reflection.
    func computePipelineState(
        function computeFunction: MTLFunction,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedComputePipelineReflection?>? = nil
    ) throws -> MTLComputePipelineState {
        try self.device.makeComputePipelineState(
            function: computeFunction,
            options: options,
            reflection: reflection
        )
    }

    /// Creates a compute pipeline state with the specified function and completion handler.
    ///
    /// - Parameters:
    ///   - computeFunction: The function for the compute pipeline state.
    ///   - completionHandler: A completion handler called when the compute pipeline state is created.
    ///
    /// This method creates a `MTLComputePipelineState` with the specified function and calls the completion handler when done.
    func computePipelineState(
        function computeFunction: MTLFunction,
        completionHandler: @escaping MTLNewComputePipelineStateCompletionHandler
    ) {
        self.device.makeComputePipelineState(
            function: computeFunction,
            completionHandler: completionHandler
        )
    }

    /// Creates a compute pipeline state with the specified function, options, and completion handler.
    ///
    /// - Parameters:
    ///   - computeFunction: The function for the compute pipeline state.
    ///   - options: The pipeline options for the compute pipeline state.
    ///   - completionHandler: A completion handler called when the compute pipeline state is created.
    ///
    /// This method creates a `MTLComputePipelineState` with the specified function, options, and calls the completion handler when done.
    func computePipelineState(
        function computeFunction: MTLFunction,
        options: MTLPipelineOption,
        completionHandler: @escaping MTLNewComputePipelineStateWithReflectionCompletionHandler
    ) {
        self.device.makeComputePipelineState(
            function: computeFunction,
            options: options,
            completionHandler: completionHandler
        )
    }

    /// Creates a compute pipeline state with the specified descriptor, options, and reflection.
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor for the compute pipeline state.
    ///   - options: The pipeline options for the compute pipeline state.
    ///   - reflection: An optional reflection object to capture detailed information about the pipeline state. Defaults to nil.
    /// - Returns: The created `MTLComputePipelineState`.
    /// - Throws: An error if the compute pipeline state creation fails.
    ///
    /// This method creates a `MTLComputePipelineState` with the specified descriptor, options, and reflection.
    func computePipelineState(
        descriptor: MTLComputePipelineDescriptor,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedComputePipelineReflection?>? = nil
    ) throws -> MTLComputePipelineState {
        try self.device.makeComputePipelineState(
            descriptor: descriptor,
            options: options,
            reflection: reflection
        )
    }

    /// Creates a compute pipeline state with the specified descriptor, options, and completion handler.
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor for the compute pipeline state.
    ///   - options: The pipeline options for the compute pipeline state.
    ///   - completionHandler: A completion handler called when the compute pipeline state is created.
    ///
    /// This method creates a `MTLComputePipelineState` with the specified descriptor, options, and calls the completion handler when done.
    func computePipelineState(
        descriptor: MTLComputePipelineDescriptor,
        options: MTLPipelineOption,
        completionHandler: @escaping MTLNewComputePipelineStateWithReflectionCompletionHandler
    ) {
        self.device.makeComputePipelineState(
            descriptor: descriptor,
            options: options,
            completionHandler: completionHandler
        )
    }

    /// Creates a fence.
    ///
    /// - Returns: The created `MTLFence`.
    /// - Throws: An error if the fence creation fails.
    ///
    /// This method creates a `MTLFence`.
    func fence() throws -> MTLFence {
        guard let fence = self.device.makeFence()
        else { throw MetalError.MTLDeviceError.fenceCreationFailed }
        return fence
    }

    /// Checks if the device supports the specified feature set.
    ///
    /// - Parameter featureSet: The feature set to check.
    /// - Returns: `true` if the device supports the feature set, otherwise `false`.
    ///
    /// This method checks if the device supports the specified feature set.
    func supportsFeatureSet(_ featureSet: MTLFeatureSet) -> Bool {
        self.device.supportsFeatureSet(featureSet)
    }

    /// Checks if the device supports the specified GPU family.
    ///
    /// - Parameter gpuFamily: The GPU family to check.
    /// - Returns: `true` if the device supports the GPU family, otherwise `false`.
    ///
    /// This method checks if the device supports the specified GPU family.
    func supportsFamily(_ gpuFamily: MTLGPUFamily) -> Bool {
        self.device.supportsFamily(gpuFamily)
    }

    /// Checks if the device supports the specified texture sample count.
    ///
    /// - Parameter sampleCount: The texture sample count to check.
    /// - Returns: `true` if the device supports the texture sample count, otherwise `false`.
    ///
    /// This method checks if the device supports the specified texture sample count.
    func supportsTextureSampleCount(_ sampleCount: Int) -> Bool {
        self.device.supportsTextureSampleCount(sampleCount)
    }

    /// Returns the minimum linear texture alignment for the specified pixel format.
    ///
    /// - Parameter format: The pixel format to query.
    /// - Returns: The minimum linear texture alignment for the specified pixel format.
    ///
    /// This method returns the minimum linear texture alignment for the specified pixel format.
    func minimumLinearTextureAlignment(for format: MTLPixelFormat) -> Int {
        self.device.minimumLinearTextureAlignment(for: format)
    }

    /// Returns the minimum texture buffer alignment for the specified pixel format.
    ///
    /// - Parameter format: The pixel format to query.
    /// - Returns: The minimum texture buffer alignment for the specified pixel format.
    ///
    /// This method returns the minimum texture buffer alignment for the specified pixel format.
    func minimumTextureBufferAlignment(for format: MTLPixelFormat) -> Int {
        self.device.minimumTextureBufferAlignment(for: format)
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    /// Creates a render pipeline state with the specified tile descriptor, options, and reflection.
    ///
    /// - Parameters:
    ///   - descriptor: The tile descriptor for the render pipeline state.
    ///   - options: The pipeline options for the render pipeline state.
    ///   - reflection: An optional reflection object to capture detailed information about the pipeline state. Defaults to nil.
    /// - Returns: The created `MTLRenderPipelineState`.
    /// - Throws: An error if the render pipeline state creation fails.
    ///
    /// This method creates a `MTLRenderPipelineState` with the specified tile descriptor, options, and reflection.
    func renderPipelineState(
        tileDescriptor descriptor: MTLTileRenderPipelineDescriptor,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedRenderPipelineReflection?>? = nil
    ) throws -> MTLRenderPipelineState {
        try self.device.makeRenderPipelineState(
            tileDescriptor: descriptor,
            options: options,
            reflection: reflection
        )
    }

    /// Creates a render pipeline state with the specified tile descriptor, options, and completion handler.
    ///
    /// - Parameters:
    ///   - descriptor: The tile descriptor for the render pipeline state.
    ///   - options: The pipeline options for the render pipeline state.
    ///   - completionHandler: A completion handler called when the render pipeline state is created.
    ///
    /// This method creates a `MTLRenderPipelineState` with the specified tile descriptor, options, and calls the completion handler when done.
    func renderPipelineState(
        tileDescriptor descriptor: MTLTileRenderPipelineDescriptor,
        options: MTLPipelineOption,
        completionHandler: @escaping MTLNewRenderPipelineStateWithReflectionCompletionHandler
    ) {
        self.device.makeRenderPipelineState(
            tileDescriptor: descriptor,
            options: options,
            completionHandler: completionHandler
        )
    }
    #endif

    /// Retrieves the default sample positions for the specified sample count.
    ///
    /// - Parameters:
    ///   - positions: A pointer to the array of sample positions.
    ///   - count: The number of sample positions to retrieve.
    ///
    /// This method retrieves the default sample positions for the specified sample count.
    func defaultSamplePositions(
        _ positions: UnsafeMutablePointer<MTLSamplePosition>,
        count: Int
    ) {
        self.device.__getDefaultSamplePositions(
            positions,
            count: count
        )
    }

    /// Creates an argument encoder for the specified argument descriptors.
    ///
    /// - Parameter arguments: An array of argument descriptors.
    /// - Returns: The created `MTLArgumentEncoder`.
    /// - Throws: An error if the argument encoder creation fails.
    ///
    /// This method creates a `MTLArgumentEncoder` for the specified argument descriptors.
    func argumentEncoder(arguments: [MTLArgumentDescriptor]) throws -> MTLArgumentEncoder {
        guard let encoder = self.device.makeArgumentEncoder(arguments: arguments)
        else { throw MetalError.MTLDeviceError.argumentEncoderCreationFailed }
        return encoder
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    /// Checks if the device supports the specified rasterization rate map layer count.
    ///
    /// - Parameter layerCount: The rasterization rate map layer count to check.
    /// - Returns: `true` if the device supports the rasterization rate map layer count, otherwise `false`.
    ///
    /// This method checks if the device supports the specified rasterization rate map layer count.
    func supportsRasterizationRateMap(layerCount: Int) -> Bool {
        self.device.supportsRasterizationRateMap(layerCount: layerCount)
    }

    /// Creates a rasterization rate map with the specified descriptor.
    ///
    /// - Parameter descriptor: The descriptor for the rasterization rate map.
    /// - Returns: The created `MTLRasterizationRateMap`.
    /// - Throws: An error if the rasterization rate map creation fails.
    ///
    /// This method creates a `MTLRasterizationRateMap` with the specified descriptor.
    func rasterizationRateMap(descriptor: MTLRasterizationRateMapDescriptor) throws -> MTLRasterizationRateMap {
        guard let map = self.device
            .makeRasterizationRateMap(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.rasterizationRateMapCreationFailed }
        return map
    }
    #endif

    /// Creates an indirect command buffer with the specified descriptor, maximum command count, and resource options.
    ///
    /// - Parameters:
    ///   - descriptor: The descriptor for the indirect command buffer.
    ///   - maxCount: The maximum command count.
    ///   - options: The resource options for the indirect command buffer. Defaults to an empty set.
    /// - Returns: The created `MTLIndirectCommandBuffer`.
    /// - Throws: An error if the indirect command buffer creation fails.
    ///
    /// This method creates a `MTLIndirectCommandBuffer` with the specified descriptor, maximum command count, and resource options.
    func indirectCommandBuffer(
        descriptor: MTLIndirectCommandBufferDescriptor,
        maxCommandCount maxCount: Int,
        options: MTLResourceOptions = []
    ) throws -> MTLIndirectCommandBuffer {
        guard let indirectCommandBuffer = self.device.makeIndirectCommandBuffer(
            descriptor: descriptor,
            maxCommandCount: maxCount,
            options: options
        )
        else { throw MetalError.MTLDeviceError.indirectCommandBufferCreationFailed }
        return indirectCommandBuffer
    }

    /// Creates an event.
    ///
    /// - Returns: The created `MTLEvent`.
    /// - Throws: An error if the event creation fails.
    ///
    /// This method creates a `MTLEvent`.
    func event() throws -> MTLEvent {
        guard let event = self.device.makeEvent()
        else { throw MetalError.MTLDeviceError.eventCreationFailed }
        return event
    }

    /// Creates a shared event.
    ///
    /// - Returns: The created `MTLSharedEvent`.
    /// - Throws: An error if the shared event creation fails.
    ///
    /// This method creates a `MTLSharedEvent`.
    func sharedEvent() throws -> MTLSharedEvent {
        guard let event = self.device.makeSharedEvent()
        else { throw MetalError.MTLDeviceError.eventCreationFailed }
        return event
    }

    /// Creates a shared event with the specified shared event handle.
    ///
    /// - Parameter sharedEventHandle: The handle for the shared event.
    /// - Returns: The created `MTLSharedEvent`.
    /// - Throws: An error if the shared event creation fails.
    ///
    /// This method creates a shared `MTLSharedEvent` with the specified shared event handle.
    func sharedEvent(handle sharedEventHandle: MTLSharedEventHandle) throws -> MTLSharedEvent {
        guard let event = self.device.makeSharedEvent(handle: sharedEventHandle)
        else { throw MetalError.MTLDeviceError.eventCreationFailed }
        return event
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    /// Returns the sparse tile size for the specified texture type, pixel format, and sample count.
    ///
    /// - Parameters:
    ///   - textureType: The texture type to query.
    ///   - pixelFormat: The pixel format to query.
    ///   - sampleCount: The sample count to query.
    /// - Returns: The sparse tile size for the specified texture type, pixel format, and sample count.
    ///
    /// This method returns the sparse tile size for the specified texture type, pixel format, and sample count.
    func sparseTileSize(
        with textureType: MTLTextureType,
        pixelFormat: MTLPixelFormat,
        sampleCount: Int
    ) -> MTLSize {
        self.device.sparseTileSize(
            with: textureType,
            pixelFormat: pixelFormat,
            sampleCount: sampleCount
        )
    }

    /// Checks if the device supports the specified vertex amplification count.
    ///
    /// - Parameter count: The vertex amplification count to check.
    /// - Returns: `true` if the device supports the vertex amplification count, otherwise `false`.
    ///
    /// This method checks if the device supports the specified vertex amplification count.
    func supportsVertexAmplificationCount(_ count: Int) -> Bool {
        self.device.supportsVertexAmplificationCount(count)
    }
    #endif

    /// Returns the default sample positions for the specified sample count.
    ///
    /// - Parameter sampleCount: The sample count to query.
    /// - Returns: An array of `MTLSamplePosition` objects representing the default sample positions.
    ///
    /// This method returns the default sample positions for the specified sample count.
    func defaultSamplePositions(sampleCount: Int) -> [MTLSamplePosition] {
        self.device.getDefaultSamplePositions(sampleCount: sampleCount)
    }
}
