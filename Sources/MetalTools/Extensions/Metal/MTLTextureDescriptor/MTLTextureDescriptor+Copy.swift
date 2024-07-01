import Foundation
import Metal

public extension MTLTextureDescriptor {

    /// Creates a deep copy of the MTLTextureDescriptor.
    ///
    /// - Returns: A new MTLTextureDescriptor instance that is a deep copy of the original.
    ///
    /// This method creates a new `MTLTextureDescriptor` and copies all the properties
    /// from the current instance, including those available in later iOS and macOS versions.
    func deepCopy() -> MTLTextureDescriptor {
        let copy = MTLTextureDescriptor()
        copy.pixelFormat = self.pixelFormat
        copy.width = self.width
        copy.height = self.height
        copy.depth = self.depth
        copy.mipmapLevelCount = self.mipmapLevelCount
        copy.sampleCount = self.sampleCount
        copy.arrayLength = self.arrayLength
        copy.resourceOptions = self.resourceOptions
        copy.cpuCacheMode = self.cpuCacheMode
        copy.storageMode = self.storageMode
        copy.usage = self.usage

        if #available(iOS 13.0, macOS 10.15, *) {
            copy.hazardTrackingMode = self.hazardTrackingMode
            copy.allowGPUOptimizedContents = self.allowGPUOptimizedContents
            copy.swizzle = self.swizzle
        }

        if #available(iOS 15.0, macOS 12.5, *) {
            copy.compressionType = self.compressionType
        }

        return copy
    }
}
