import Metal

public extension MTLDevice {
    var isDiscrete: Bool {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return !self.isLowPower
        #else
        return false
        #endif
    }
}
