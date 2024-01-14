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
        if self.isSynchronizable {
            commandBuffer.blit { $0.synchronize(resource: self) }
        }
        #endif
    }
}

public extension Array where Element == MTLResource {
    func synchronizeIfNeeded(in commandBuffer: MTLCommandBuffer) {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        let synchronizableResources = filter(\.isSynchronizable)
        guard !synchronizableResources.isEmpty else { return }
        commandBuffer.blit { encoder in
            synchronizableResources.forEach {
                encoder.synchronize(resource: $0)
            }
        }
        #endif
    }
}
