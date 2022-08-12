import Metal

public extension MTLResource {

    var isAccessibleOnCPU: Bool {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return self.storageMode == .managed || self.storageMode == .shared
        #else
        return self.storageMode == .shared
        #endif
    }
    
    var isSynchronizable: Bool {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return self.storageMode == .managed && self.device.isDiscrete
        #else
        return false
        #endif
    }
    
    func synchronizeIfNeeded(in commandBuffer: MTLCommandBuffer) {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        if self.isSynchronizable, commandBuffer.device == self.device {
            commandBuffer.blit { $0.synchronize(resource: self) }
        }
        #endif
    }

}
