import Metal

/// Extension to the MTLResourceOptions enum to provide cross-platform compatibility.
public extension MTLResourceOptions {

    /// A computed property that returns the appropriate MTLResourceOptions value
    /// based on the platform and architecture.
    ///
    /// - For macOS and Mac Catalyst running on x86_64 architecture, it returns `.storageModeManaged`.
    /// - For other platforms and architectures, it returns `.storageModeShared`.
    ///
    /// This allows for seamless cross-platform development by abstracting away
    /// the differences in resource storage modes.
    static var crossPlatformSharedOrManaged: MTLResourceOptions {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return .storageModeManaged
        #else
        return .storageModeShared
        #endif
    }
}
