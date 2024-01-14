import Metal

public extension MTLStorageMode {
    static var crossPlatformSharedOrManaged: MTLStorageMode {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return .managed
        #else
        return .shared
        #endif
    }
}
