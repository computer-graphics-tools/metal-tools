@_exported import Foundation
@_exported import Metal
@_exported import MetalKit
@_exported import MetalPerformanceShaders

public final class Metal {
    public static let device: MTLDevice! = MTLCreateSystemDefaultDevice()

    #if os(macOS) || targetEnvironment(macCatalyst)
    public static let lowPowerDevice: MTLDevice? = MTLCopyAllDevices().first { $0.isLowPower }
    #endif // os(macOS) || targetEnvironment(macCatalyst)

    public static var isAvailable: Bool { Metal.device != nil }
}
