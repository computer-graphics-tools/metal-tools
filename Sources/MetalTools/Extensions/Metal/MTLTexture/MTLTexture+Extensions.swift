import Foundation
import CoreGraphics
import MetalKit
import MetalPerformanceShaders
import Accelerate

public extension MTLTexture {
    
    var region: MTLRegion {
        .init(origin: .zero,
              size: self.size)
    }
    
    var size: MTLSize {
        .init(width: self.width,
              height: self.height,
              depth: self.depth)
    }
    
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
    
    func matchingTexture(usage: MTLTextureUsage? = nil,
                         storage: MTLStorageMode? = nil) throws -> MTLTexture {
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
    
    func matchingTemporaryImage(commandBuffer: MTLCommandBuffer,
                                usage: MTLTextureUsage? = nil) -> MPSTemporaryImage {
        let matchingDescriptor = self.descriptor
        
        if let u = usage {
            matchingDescriptor.usage = u
        }
        // it has to be enforced for temporary image
        matchingDescriptor.storageMode = .private
        
        return MPSTemporaryImage(commandBuffer: commandBuffer, textureDescriptor: matchingDescriptor)
    }
    
    func view(slice: Int,
              levels: Range<Int>? = nil) -> MTLTexture? {
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

        return self.makeTextureView(pixelFormat: self.pixelFormat,
                                    textureType: sliceType,
                                    levels: levels ?? 0..<1,
                                    slices: slice..<(slice + 1))
    }

    func view(level: Int) -> MTLTexture? {
        let levels = level ..< (level + 1)
        return self.view(slice: 0,
                         levels: levels)
    }
}

