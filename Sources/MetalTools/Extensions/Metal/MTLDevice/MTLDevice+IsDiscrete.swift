import Metal

public extension MTLDevice {
    /// Indicates whether the device is a discrete GPU.
    ///
    /// This property is `true` for discrete GPUs on Mac platforms (macOS and Mac Catalyst).
    /// It's always `false` for other platforms or architectures.
    ///
    /// - Note: This property relies on the `isLowPower` property, which is only available
    ///         on Mac platforms with x86_64 architecture. On other platforms, it always
    ///         returns `false`.
    var isDiscrete: Bool {
        #if arch(x86_64) && (os(macOS) || targetEnvironment(macCatalyst))
        return !self.isLowPower
        #else
        return false
        #endif
    }
}
