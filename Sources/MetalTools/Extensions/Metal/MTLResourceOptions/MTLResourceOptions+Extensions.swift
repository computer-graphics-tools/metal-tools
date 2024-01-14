import Metal

extension MTLResourceOptions {
    static var crossPlatformSharedOrManaged: MTLResourceOptions {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return .storageModeManaged
        #else
        return .storageModeShared
        #endif
    }
}
