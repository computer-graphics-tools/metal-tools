import Metal

/// A utility class that provides access to Metal devices and checks for Metal availability.
public final class Metal {

    /// The default Metal device.
    ///
    /// This property provides the system's default Metal device. If Metal is not supported on the device, this value will be `nil`.
    public static let device: MTLDevice! = MTLCreateSystemDefaultDevice()

    #if os(macOS) || targetEnvironment(macCatalyst)
    /// The low-power Metal device, if available.
    ///
    /// On macOS and Mac Catalyst, this property provides the first low-power Metal device found. If no low-power device is available, this value will be `nil`.
    public static let lowPowerDevice: MTLDevice? = MTLCopyAllDevices().first { $0.isLowPower }
    #endif // os(macOS) || targetEnvironment(macCatalyst)

    /// A Boolean value indicating whether Metal is available on the device.
    ///
    /// This property checks if the system's default Metal device is available.
    public static var isAvailable: Bool { Metal.device != nil }
}
