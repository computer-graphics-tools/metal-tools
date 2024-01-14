import Metal

public extension MTLContext {
    // MARK: - MetalTools API

    func maxTextureSize(desiredSize: MTLSize) -> MTLSize {
        self.device.maxTextureSize(desiredSize: desiredSize)
    }

    func library(
        from file: URL,
        options: MTLCompileOptions? = nil
    ) throws -> MTLLibrary {
        try self.device.library(
            from: file,
            options: options
        )
    }

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

    func depthState(
        depthCompareFunction: MTLCompareFunction,
        isDepthWriteEnabled: Bool = true
    ) throws -> MTLDepthStencilState {
        try self.device.depthState(
            depthCompareFunction: depthCompareFunction,
            isDepthWriteEnabled: isDepthWriteEnabled
        )
    }

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

    func buffer<T>(
        with value: T,
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        try self.device.buffer(
            with: value,
            options: options
        )
    }

    func buffer<T>(
        with values: [T],
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        try self.device.buffer(
            with: values,
            options: options
        )
    }

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

    var maxThreadgroupMemoryLength: Int {
        self.device.maxThreadgroupMemoryLength
    }

    var maxArgumentBufferSamplerCount: Int {
        self.device.maxArgumentBufferSamplerCount
    }

    var areProgrammableSamplePositionsSupported: Bool {
        self.device.areProgrammableSamplePositionsSupported
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    var sparseTileSizeInBytes: Int {
        self.device.sparseTileSizeInBytes
    }
    #endif

    var maxBufferLength: Int {
        self.device.maxBufferLength
    }

    var deviceName: String {
        self.device.name
    }

    var registryID: UInt64 {
        self.device.registryID
    }

    var maxThreadsPerThreadgroup: MTLSize {
        self.device.maxThreadsPerThreadgroup
    }

    var hasUnifiedMemory: Bool {
        self.device.hasUnifiedMemory
    }

    var readWriteTextureSupport: MTLReadWriteTextureTier {
        self.device.readWriteTextureSupport
    }

    var argumentBuffersSupport: MTLArgumentBuffersTier {
        self.device.argumentBuffersSupport
    }

    var areRasterOrderGroupsSupported: Bool {
        self.device.areRasterOrderGroupsSupported
    }

    var currentAllocatedSize: Int {
        self.device.currentAllocatedSize
    }

    func heapTextureSizeAndAlign(descriptor desc: MTLTextureDescriptor) -> MTLSizeAndAlign {
        self.device.heapTextureSizeAndAlign(descriptor: desc)
    }

    func heapBufferSizeAndAlign(
        length: Int,
        options: MTLResourceOptions = []
    ) -> MTLSizeAndAlign {
        self.device.heapBufferSizeAndAlign(
            length: length,
            options: options
        )
    }

    func heap(descriptor: MTLHeapDescriptor) -> MTLHeap? {
        self.device.makeHeap(descriptor: descriptor)
    }

    func buffer(
        length: Int,
        options: MTLResourceOptions = []
    ) -> MTLBuffer? {
        self.device.makeBuffer(
            length: length,
            options: options
        )
    }

    func buffer(
        bytes pointer: UnsafeRawPointer,
        length: Int,
        options: MTLResourceOptions = []
    ) -> MTLBuffer? {
        self.device.makeBuffer(
            bytes: pointer,
            length: length,
            options: options
        )
    }

    func buffer(
        bytesNoCopy pointer: UnsafeMutableRawPointer,
        length: Int,
        options: MTLResourceOptions = [],
        deallocator: ((UnsafeMutableRawPointer, Int) -> Void)? = nil
    ) -> MTLBuffer? {
        self.device.makeBuffer(
            bytesNoCopy: pointer,
            length: length,
            options: options,
            deallocator: deallocator
        )
    }

    func depthStencilState(descriptor: MTLDepthStencilDescriptor) -> MTLDepthStencilState? {
        self.device.makeDepthStencilState(descriptor: descriptor)
    }

    func texture(descriptor: MTLTextureDescriptor) throws -> MTLTexture {
        guard let texture = self.device.makeTexture(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }

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
    // Probably it's a bug, but simulator's version of `MTLDevice`
    // doesn't know about `makeSharedTexture`.
    func sharedTexture(descriptor: MTLTextureDescriptor) throws -> MTLTexture {
        guard let texture = self.device.makeSharedTexture(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }

    func sharedTexture(handle sharedHandle: MTLSharedTextureHandle) throws -> MTLTexture {
        guard let texture = self.device.makeSharedTexture(handle: sharedHandle)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }
    #endif

    func samplerState(descriptor: MTLSamplerDescriptor) throws -> MTLSamplerState {
        guard let samplerState = self.device.makeSamplerState(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.samplerStateCreationFailed }
        return samplerState
    }

    func library(filepath: String) throws -> MTLLibrary {
        try self.device.makeLibrary(filepath: filepath)
    }

    func library(URL url: URL) throws -> MTLLibrary {
        try self.device.makeLibrary(URL: url)
    }

    func library(data: __DispatchData) throws -> MTLLibrary {
        try self.device.makeLibrary(data: data)
    }

    func library(
        source: String,
        options: MTLCompileOptions?
    ) throws -> MTLLibrary {
        try self.device.makeLibrary(
            source: source,
            options: options
        )
    }

    func library(
        source: String,
        options: MTLCompileOptions?,
        completionHandler: @escaping MTLNewLibraryCompletionHandler
    ) {
        self.device.makeLibrary(
            source: source,
            options: options,
            completionHandler: completionHandler
        )
    }

    func renderPipelineState(descriptor: MTLRenderPipelineDescriptor) throws -> MTLRenderPipelineState {
        try self.device.makeRenderPipelineState(descriptor: descriptor)
    }

    func renderPipelineState(
        descriptor: MTLRenderPipelineDescriptor,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedRenderPipelineReflection?>?
    ) throws -> MTLRenderPipelineState {
        try self.device.makeRenderPipelineState(
            descriptor: descriptor,
            options: options,
            reflection: reflection
        )
    }

    func renderPipelineState(
        descriptor: MTLRenderPipelineDescriptor,
        completionHandler: @escaping MTLNewRenderPipelineStateCompletionHandler
    ) {
        self.device.makeRenderPipelineState(
            descriptor: descriptor,
            completionHandler: completionHandler
        )
    }

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

    func computePipelineState(function computeFunction: MTLFunction) throws -> MTLComputePipelineState {
        try self.device.makeComputePipelineState(function: computeFunction)
    }

    func computePipelineState(
        function computeFunction: MTLFunction,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedComputePipelineReflection?>?
    ) throws -> MTLComputePipelineState {
        try self.device.makeComputePipelineState(
            function: computeFunction,
            options: options,
            reflection: reflection
        )
    }

    func computePipelineState(
        function computeFunction: MTLFunction,
        completionHandler: @escaping MTLNewComputePipelineStateCompletionHandler
    ) {
        self.device.makeComputePipelineState(
            function: computeFunction,
            completionHandler: completionHandler
        )
    }

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

    func computePipelineState(
        descriptor: MTLComputePipelineDescriptor,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedComputePipelineReflection?>?
    ) throws -> MTLComputePipelineState {
        try self.device.makeComputePipelineState(
            descriptor: descriptor,
            options: options,
            reflection: reflection
        )
    }

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

    func fence() throws -> MTLFence {
        guard let fence = self.device.makeFence()
        else { throw MetalError.MTLDeviceError.fenceCreationFailed }
        return fence
    }

    func supportsFeatureSet(_ featureSet: MTLFeatureSet) -> Bool {
        self.device.supportsFeatureSet(featureSet)
    }

    func supportsFamily(_ gpuFamily: MTLGPUFamily) -> Bool {
        self.device.supportsFamily(gpuFamily)
    }

    func supportsTextureSampleCount(_ sampleCount: Int) -> Bool {
        self.device.supportsTextureSampleCount(sampleCount)
    }

    func minimumLinearTextureAlignment(for format: MTLPixelFormat) -> Int {
        self.device.minimumLinearTextureAlignment(for: format)
    }

    func minimumTextureBufferAlignment(for format: MTLPixelFormat) -> Int {
        self.device.minimumTextureBufferAlignment(for: format)
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    func renderPipelineState(
        tileDescriptor descriptor: MTLTileRenderPipelineDescriptor,
        options: MTLPipelineOption,
        reflection: AutoreleasingUnsafeMutablePointer<MTLAutoreleasedRenderPipelineReflection?>?
    ) throws -> MTLRenderPipelineState {
        try self.device.makeRenderPipelineState(
            tileDescriptor: descriptor,
            options: options,
            reflection: reflection
        )
    }

    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
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

    func defaultSamplePositions(
        _ positions: UnsafeMutablePointer<MTLSamplePosition>,
        count: Int
    ) {
        self.device.__getDefaultSamplePositions(
            positions,
            count: count
        )
    }

    func argumentEncoder(arguments: [MTLArgumentDescriptor]) throws -> MTLArgumentEncoder {
        guard let encoder = self.device.makeArgumentEncoder(arguments: arguments)
        else { throw MetalError.MTLDeviceError.argumentEncoderCreationFailed }
        return encoder
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    func supportsRasterizationRateMap(layerCount: Int) -> Bool {
        self.device.supportsRasterizationRateMap(layerCount: layerCount)
    }

    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    func rasterizationRateMap(descriptor: MTLRasterizationRateMapDescriptor) throws -> MTLRasterizationRateMap {
        guard let map = self.device
            .makeRasterizationRateMap(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.rasterizationRateMapCreationFailed }
        return map
    }
    #endif

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

    func event() throws -> MTLEvent {
        guard let event = self.device.makeEvent()
        else { throw MetalError.MTLDeviceError.eventCreationFailed }
        return event
    }

    func sharedEvent() throws -> MTLSharedEvent {
        guard let event = self.device.makeSharedEvent()
        else { throw MetalError.MTLDeviceError.eventCreationFailed }
        return event
    }

    func sharedEvent(handle sharedEventHandle: MTLSharedEventHandle) throws -> MTLSharedEvent {
        guard let event = self.device.makeSharedEvent(handle: sharedEventHandle)
        else { throw MetalError.MTLDeviceError.eventCreationFailed }
        return event
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
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

    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    func supportsVertexAmplificationCount(_ count: Int) -> Bool {
        self.device.supportsVertexAmplificationCount(count)
    }
    #endif

    func defaultSamplePositions(sampleCount: Int) -> [MTLSamplePosition] {
        self.device.getDefaultSamplePositions(sampleCount: sampleCount)
    }
}
