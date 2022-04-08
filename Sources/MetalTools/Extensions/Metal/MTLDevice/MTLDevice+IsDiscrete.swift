import Metal

public extension MTLDevice {
    var isDiscrete: Bool {
        #if !arch(arm64) && targetEnvironment(macCatalyst)
        return !self.isLowPower
        #else
        return false
        #endif
    }
}
