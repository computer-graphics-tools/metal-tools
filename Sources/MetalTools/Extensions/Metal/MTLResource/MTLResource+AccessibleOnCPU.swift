import Metal

public extension MTLResource {
    /// Indicates whether the resource is accessible on the CPU.
    ///
    /// On macOS and Mac Catalyst (x86_64), this is true for managed or shared storage modes.
    /// On other platforms, this is true only for shared storage mode.
    var isAccessibleOnCPU: Bool {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return self.storageMode == .managed || self.storageMode == .shared
        #else
        return self.storageMode == .shared
        #endif
    }

    /// Indicates whether the resource requires synchronization.
    ///
    /// This is only true for managed resources on discrete GPUs on macOS and Mac Catalyst (x86_64).
    var isSynchronizable: Bool {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return self.storageMode == .managed && self.device.isDiscrete
        #else
        return false
        #endif
    }

    /// Synchronizes the resource if necessary.
    ///
    /// This method only performs synchronization on macOS and Mac Catalyst (x86_64) for managed resources on discrete GPUs.
    ///
    /// - Parameter commandBuffer: The command buffer in which to perform the synchronization.
    func synchronizeIfNeeded(in commandBuffer: MTLCommandBuffer) {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        if self.isSynchronizable {
            commandBuffer.blit { $0.synchronize(resource: self) }
        }
        #endif
    }
}

public extension Array where Element == MTLResource {
    /// Synchronizes all resources in the array that require synchronization.
    ///
    /// This method only performs synchronization on macOS and Mac Catalyst (x86_64) for managed resources on discrete GPUs.
    ///
    /// - Parameter commandBuffer: The command buffer in which to perform the synchronization.
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
