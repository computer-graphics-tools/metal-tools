import Metal
import MetalKit

public final class MTLContext {
    // MARK: - Properties

    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    private var libraryCache: [Bundle: MTLLibrary] = [:]

    // MARK: - Init

    public init(commandQueue: MTLCommandQueue) {
        self.device = commandQueue.device
        self.commandQueue = commandQueue
    }

    public convenience init(
        device: MTLDevice = Metal.device,
        bundle: Bundle = .main,
        libraryName: String? = nil
    ) throws {
        guard let commandQueue = device.makeCommandQueue()
        else { throw MetalError.MTLDeviceError.commandQueueCreationFailed }

        var library: MTLLibrary?

        if libraryName == nil {
            if let bundleDefaultLibrary = try? device.makeDefaultLibrary(bundle: bundle) {
                library = bundleDefaultLibrary
            } else {
                library = device.makeDefaultLibrary()
            }
        } else if let name = libraryName,
                  let path = bundle.path(forResource: name, ofType: "metallib")
        {
            library = try device.makeLibrary(filepath: path)
        }

        self.init(commandQueue: commandQueue)
        self.libraryCache[bundle] = library
    }

    public func library(for class: AnyClass) throws -> MTLLibrary {
        try self.library(for: Bundle(for: `class`))
    }

    public func library(for bundle: Bundle) throws -> MTLLibrary {
        if self.libraryCache[bundle] == nil {
            self.libraryCache[bundle] = try self.device.makeDefaultLibrary(bundle: bundle)
        }
        return self.libraryCache[bundle]!
    }

    public func purgeLibraryCache() {
        self.libraryCache = [:]
    }
}

