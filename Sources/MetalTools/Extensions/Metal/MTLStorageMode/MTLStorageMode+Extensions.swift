import Metal

/// Extension to the MTLStorageMode enum to provide cross-platform compatibility.
public extension MTLStorageMode {

    /// A computed property that returns the appropriate MTLStorageMode value
    /// based on the platform and architecture.
    ///
    /// - For macOS and Mac Catalyst running on x86_64 architecture, it returns `.managed`.
    /// - For other platforms and architectures, it returns `.shared`.
    ///
    /// This allows for seamless cross-platform development by abstracting away
    /// the differences in storage modes.
    static var crossPlatformSharedOrManaged: MTLStorageMode {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return .managed
        #else
        return .shared
        #endif
    }
}
