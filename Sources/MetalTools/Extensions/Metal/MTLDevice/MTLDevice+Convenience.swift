import IOSurface
import Metal

public extension MTLDevice {
    /// Creates a Metal library from a file at the given URL.
    ///
    /// - Parameters:
    ///   - file: The URL of the Metal source file.
    ///   - options: Compile options for the library (optional).
    /// - Returns: A compiled Metal library.
    /// - Throws: An error if the library creation fails.
    func library(
        from file: URL,
        options: MTLCompileOptions? = nil
    ) throws -> MTLLibrary {
        try self.makeLibrary(
            source: try String(contentsOf: file),
            options: options
        )
    }

    /// Creates a pair of textures for multisample rendering.
    ///
    /// - Parameters:
    ///   - width: The width of the textures.
    ///   - height: The height of the textures.
    ///   - pixelFormat: The pixel format of the textures.
    ///   - sampleCount: The number of samples for multisampling (default is 4).
    /// - Returns: A tuple containing the main (multisample) texture and the resolve texture.
    /// - Throws: An error if texture creation fails.
    func multisampleRenderTargetPair(
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        sampleCount: Int = 4
    ) throws -> (
        main: MTLTexture,
        resolve: MTLTexture
    ) {
        let mainDescriptor = MTLTextureDescriptor()
        mainDescriptor.width = width
        mainDescriptor.height = height
        mainDescriptor.pixelFormat = pixelFormat
        mainDescriptor.usage = [.renderTarget, .shaderRead]

        let sampleDescriptor = MTLTextureDescriptor()
        sampleDescriptor.textureType = MTLTextureType.type2DMultisample
        sampleDescriptor.width = width
        sampleDescriptor.height = height
        sampleDescriptor.sampleCount = sampleCount
        sampleDescriptor.pixelFormat = pixelFormat
        #if !os(macOS) && !targetEnvironment(macCatalyst)
        sampleDescriptor.storageMode = .memoryless
        #endif
        sampleDescriptor.usage = .renderTarget

        guard let mainTex = makeTexture(descriptor: mainDescriptor),
              let sampleTex = makeTexture(descriptor: sampleDescriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }

        return (main: sampleTex, resolve: mainTex)
    }

    /// Creates a Metal heap with the specified size and storage mode.
    ///
    /// - Parameters:
    ///   - size: The size of the heap in bytes.
    ///   - storageMode: The storage mode for the heap.
    ///   - cpuCacheMode: The CPU cache mode for the heap (default is .defaultCache).
    /// - Returns: A new Metal heap.
    /// - Throws: An error if heap creation fails.
    func heap(
        size: Int,
        storageMode: MTLStorageMode,
        cpuCacheMode: MTLCPUCacheMode = .defaultCache
    ) throws -> MTLHeap {
        let descriptor = MTLHeapDescriptor()
        descriptor.size = size
        descriptor.storageMode = storageMode
        descriptor.cpuCacheMode = cpuCacheMode

        guard let heap = makeHeap(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.heapCreationFailed }
        return heap
    }

    /// Creates a Metal buffer for a specific type.
    ///
    /// - Parameters:
    ///   - _: The type of elements the buffer will hold.
    ///   - count: The number of elements (default is 1).
    ///   - options: Resource options for the buffer (default is .cpuCacheModeWriteCombined).
    /// - Returns: A new Metal buffer.
    /// - Throws: An error if buffer creation fails.
    func buffer<T>(
        for _: T.Type,
        count: Int = 1,
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        guard let buffer = makeBuffer(
            length: MemoryLayout<T>.stride * count,
            options: options
        )
        else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    /// Creates a Metal buffer containing a single value.
    ///
    /// - Parameters:
    ///   - value: The value to store in the buffer.
    ///   - options: Resource options for the buffer (default is .cpuCacheModeWriteCombined).
    /// - Returns: A new Metal buffer containing the value.
    /// - Throws: An error if buffer creation fails.
    func buffer<T>(
        with value: T,
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        guard let buffer = withUnsafePointer(to: value, {
            makeBuffer(
                bytes: $0,
                length: MemoryLayout<T>.stride,
                options: options
            )
        })
        else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    /// Creates a Metal buffer containing an array of values.
    ///
    /// - Parameters:
    ///   - values: The array of values to store in the buffer.
    ///   - options: Resource options for the buffer (default is .cpuCacheModeWriteCombined).
    /// - Returns: A new Metal buffer containing the values.
    /// - Throws: An error if buffer creation fails.
    func buffer<T>(
        with values: [T],
        options: MTLResourceOptions = .cpuCacheModeWriteCombined
    ) throws -> MTLBuffer {
        let buffer = values.withUnsafeBytes {
            $0.baseAddress.map {
                makeBuffer(
                    bytes: $0,
                    length: MemoryLayout<T>.stride * values.count,
                    options: options
                )
            } ?? nil
        }
        guard let buffer else { throw MetalError.MTLDeviceError.bufferCreationFailed }
        return buffer
    }

    /// Creates a depth buffer texture.
    ///
    /// - Parameters:
    ///   - width: The width of the texture.
    ///   - height: The height of the texture.
    ///   - usage: The usage of the texture (default is empty).
    ///   - storageMode: The storage mode of the texture (default is platform-specific).
    /// - Returns: A new depth buffer texture.
    /// - Throws: An error if texture creation fails.
    func depthBuffer(
        width: Int,
        height: Int,
        usage: MTLTextureUsage = [],
        storageMode: MTLStorageMode? = nil
    ) throws -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = width
        textureDescriptor.height = height
        textureDescriptor.pixelFormat = .depth32Float
        textureDescriptor.usage = usage.union([.renderTarget])
        #if !os(macOS) && !targetEnvironment(macCatalyst)
        textureDescriptor.storageMode = storageMode ?? .memoryless
        #else
        textureDescriptor.storageMode = storageMode ?? .private
        #endif
        guard let texture = makeTexture(descriptor: textureDescriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }

    /// Creates a depth stencil state.
    ///
    /// - Parameters:
    ///   - depthCompareFunction: The depth comparison function to use.
    ///   - isDepthWriteEnabled: Whether depth writing is enabled (default is true).
    /// - Returns: A new depth stencil state.
    /// - Throws: An error if depth stencil state creation fails.
    func depthState(
        depthCompareFunction: MTLCompareFunction,
        isDepthWriteEnabled: Bool = true
    ) throws -> MTLDepthStencilState {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = depthCompareFunction
        descriptor.isDepthWriteEnabled = isDepthWriteEnabled
        guard let depthStencilState = makeDepthStencilState(descriptor: descriptor)
        else { throw MetalError.MTLDeviceError.depthStencilStateCreationFailed }
        return depthStencilState
    }

    /// Creates a texture with the specified parameters.
    ///
    /// - Parameters:
    ///   - width: The width of the texture.
    ///   - height: The height of the texture.
    ///   - pixelFormat: The pixel format of the texture.
    ///   - options: Resource options for the texture (default is empty).
    ///   - usage: The usage of the texture (default is empty).
    /// - Returns: A new texture.
    /// - Throws: An error if texture creation fails.
    func texture(
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        options: MTLResourceOptions = [],
        usage: MTLTextureUsage = []
    ) throws -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.width = width
        textureDescriptor.height = height
        textureDescriptor.pixelFormat = pixelFormat
        textureDescriptor.resourceOptions = options
        textureDescriptor.usage = usage
        guard let texture = makeTexture(descriptor: textureDescriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        return texture
    }

    /// Creates a texture from an IOSurface.
    ///
    /// - Parameters:
    ///   - iosurface: The IOSurface to create the texture from.
    ///   - plane: The plane of the IOSurface to use (default is 0).
    ///   - options: Resource options for the texture (default is empty).
    ///   - usage: The usage of the texture (default is empty).
    /// - Returns: A new texture created from the IOSurface.
    /// - Throws: An error if texture creation fails.
    func texture(
        iosurface: IOSurfaceRef,
        plane: Int = 0,
        options: MTLResourceOptions = [],
        usage: MTLTextureUsage = []
    ) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = IOSurfaceGetWidthOfPlane(iosurface, plane)
        descriptor.height = IOSurfaceGetHeightOfPlane(iosurface, plane)
        descriptor.pixelFormat = try .init(osType: IOSurfaceGetPixelFormat(iosurface))
        descriptor.resourceOptions = options
        descriptor.usage = usage

        guard let texture = makeTexture(
            descriptor: descriptor,
            iosurface: iosurface,
            plane: plane
        )
        else { throw MetalError.MTLDeviceError.textureCreationFailed }

        return texture
    }

    /// Calculates the maximum texture size that can be supported by the device.
    ///
    /// - Parameter desiredSize: The desired size of the texture.
    /// - Returns: The maximum supported size, maintaining the aspect ratio of the desired size.
    func maxTextureSize(desiredSize: MTLSize) -> MTLSize {
        let maxSide: Int
        if self.supportsOnly8K() {
            maxSide = 8192
        } else {
            maxSide = 16384
        }

        guard desiredSize.width > 0,
              desiredSize.height > 0
        else { return .zero }

        let aspectRatio = Float(desiredSize.width) / Float(desiredSize.height)
        if aspectRatio > 1 {
            let resultWidth = min(desiredSize.width, maxSide)
            let resultHeight = Float(resultWidth) / aspectRatio
            return MTLSize(width: resultWidth, height: Int(resultHeight.rounded()), depth: 0)
        } else {
            let resultHeight = min(desiredSize.height, maxSide)
            let resultWidth = Float(resultHeight) * aspectRatio
            return MTLSize(width: Int(resultWidth.rounded()), height: resultHeight, depth: 0)
        }
    }
    
    // Private helper method
    private func supportsOnly8K() -> Bool {
        #if targetEnvironment(macCatalyst)
        return !supportsFamily(.apple3)
        #elseif os(macOS)
        return false
        #else
        if #available(iOS 13.0, *) {
            return !supportsFamily(.apple3)
        } else {
            return !supportsFeatureSet(.iOS_GPUFamily3_v3)
        }
        #endif
    }
}
