import Accelerate
import CoreGraphics
import Foundation
import MetalKit
import MetalPerformanceShaders

public extension MTLTexture {
    /// A computed property that returns the MTLRegion covering the entire texture.
    ///
    /// The region's origin is set to zero and its size is set to the texture's size.
    var region: MTLRegion {
        MTLRegion(
            origin: .zero,
            size: self.size
        )
    }

    /// A computed property that returns the MTLSize representing the texture's dimensions.
    ///
    /// The size includes the texture's width, height, and depth.
    var size: MTLSize {
        MTLSize(
            width: self.width,
            height: self.height,
            depth: self.depth
        )
    }

    /// A computed property that returns an MTLTextureDescriptor configured to match the texture's properties.
    ///
    /// The descriptor includes width, height, depth, array length, storage mode,
    /// CPU cache mode, usage, texture type, sample count, mipmap level count, and pixel format.
    var descriptor: MTLTextureDescriptor {
        let descriptor = MTLTextureDescriptor()

        descriptor.width = self.width
        descriptor.height = self.height
        descriptor.depth = self.depth
        descriptor.arrayLength = self.arrayLength
        descriptor.storageMode = self.storageMode
        descriptor.cpuCacheMode = self.cpuCacheMode
        descriptor.usage = self.usage
        descriptor.textureType = self.textureType
        descriptor.sampleCount = self.sampleCount
        descriptor.mipmapLevelCount = self.mipmapLevelCount
        descriptor.pixelFormat = self.pixelFormat
        if #available(iOS 12, macOS 10.14, *) {
            descriptor.allowGPUOptimizedContents = self.allowGPUOptimizedContents
        }

        return descriptor
    }

    /// Creates a new texture that matches the current texture's properties, with optional overrides.
    ///
    /// - Parameters:
    ///   - usage: Optional. The usage for the new texture.
    ///   - storage: Optional. The storage mode for the new texture.
    /// - Returns: A new MTLTexture instance that matches the current texture's properties with the specified overrides.
    /// - Throws: An error if the texture creation fails.
    ///
    /// This method creates a new texture using a descriptor that matches the current texture's properties.
    /// You can optionally override the usage and storage mode.
    func matchingTexture(
        usage: MTLTextureUsage? = nil,
        storage: MTLStorageMode? = nil
    ) throws -> MTLTexture {
        let matchingDescriptor = self.descriptor

        if let u = usage {
            matchingDescriptor.usage = u
        }
        if let s = storage {
            matchingDescriptor.storageMode = s
        }

        guard let matchingTexture = self.device.makeTexture(descriptor: matchingDescriptor)
        else { throw MetalError.MTLDeviceError.textureCreationFailed }

        return matchingTexture
    }

    /// Creates a new MPSTemporaryImage that matches the current texture's properties, with optional overrides.
    ///
    /// - Parameters:
    ///   - commandBuffer: The command buffer to use for the temporary image.
    ///   - usage: Optional. The usage for the temporary image.
    /// - Returns: A new MPSTemporaryImage instance that matches the current texture's properties with the specified usage.
    ///
    /// This method creates a new temporary image using a descriptor that matches the current texture's properties.
    /// You can optionally override the usage.
    func matchingTemporaryImage(
        commandBuffer: MTLCommandBuffer,
        usage: MTLTextureUsage? = nil
    ) -> MPSTemporaryImage {
        let matchingDescriptor = self.descriptor

        if let u = usage {
            matchingDescriptor.usage = u
        }
        // it has to be enforced for temporary image
        matchingDescriptor.storageMode = .private

        return MPSTemporaryImage(commandBuffer: commandBuffer, textureDescriptor: matchingDescriptor)
    }

    /// Creates a texture view for a specific slice and mipmap levels.
    ///
    /// - Parameters:
    ///   - slice: The slice of the texture array to create the view for.
    ///   - levels: Optional. The range of mipmap levels to include in the view. Defaults to the first level.
    /// - Returns: An optional MTLTexture representing the view of the specified slice and levels.
    ///
    /// This method creates a texture view for a specified slice and range of mipmap levels.
    /// It handles different texture types and ensures the slice is valid.
    func view(
        slice: Int,
        levels: Range<Int>? = nil
    ) -> MTLTexture? {
        let sliceType: MTLTextureType

        switch self.textureType {
        case .type1DArray: sliceType = .type1D
        case .type2DArray: sliceType = .type2D
        case .typeCubeArray: sliceType = .typeCube
        default:
            guard slice == 0
            else { return nil }
            sliceType = self.textureType
        }

        return self.makeTextureView(
            pixelFormat: self.pixelFormat,
            textureType: sliceType,
            levels: levels ?? 0..<1,
            slices: slice..<(slice + 1)
        )
    }
    
    /// Creates a texture view for a specific mipmap level.
    ///
    /// - Parameter level: The mipmap level to create the view for.
    /// - Returns: An optional MTLTexture representing the view of the specified mipmap level.
    ///
    /// This method creates a texture view for a specific mipmap level, using the first slice of the texture.
    func view(level: Int) -> MTLTexture? {
        self.view(
            slice: 0,
            levels: level ..< (level + 1)
        )
    }
}

