import Metal
import MetalKit

/// A context for managing Metal objects and resources.
public final class MTLContext {
    // MARK: - Properties

    /// The Metal device associated with this context.
    public let device: MTLDevice

    /// The command queue associated with this context.
    public let commandQueue: MTLCommandQueue

    /// A cache for storing compiled Metal libraries.
    private var libraryCache: [Bundle: MTLLibrary] = [:]

    // MARK: - Init

    /// Initializes a new MTLContext with the specified command queue.
    ///
    /// - Parameter commandQueue: The command queue to use for this context.
    ///
    /// This initializer sets the device and command queue properties based on the provided command queue.
    public init(commandQueue: MTLCommandQueue) {
        self.device = commandQueue.device
        self.commandQueue = commandQueue
    }

    /// Initializes a new MTLContext with the specified device, bundle, and library name.
    ///
    /// - Parameters:
    ///   - device: The Metal device to use. Defaults to the system's default Metal device.
    ///   - bundle: The bundle containing the Metal library. Defaults to the main bundle.
    ///   - libraryName: The name of the Metal library. Defaults to nil.
    /// - Throws: An error if the command queue or library creation fails.
    ///
    /// This initializer creates a command queue for the specified device and attempts to load the Metal library from the specified bundle and library name.
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

    /// Returns the Metal library associated with the specified class.
    ///
    /// - Parameter class: The class whose bundle contains the Metal library.
    /// - Returns: The `MTLLibrary` associated with the class.
    /// - Throws: An error if the library creation fails.
    ///
    /// This method retrieves the Metal library for the bundle that contains the specified class.
    public func library(for class: AnyClass) throws -> MTLLibrary {
        try self.library(for: Bundle(for: `class`))
    }

    /// Returns the Metal library associated with the specified bundle.
    ///
    /// - Parameter bundle: The bundle containing the Metal library.
    /// - Returns: The `MTLLibrary` associated with the bundle.
    /// - Throws: An error if the library creation fails.
    ///
    /// This method retrieves the Metal library for the specified bundle, caching it if necessary.
    public func library(for bundle: Bundle) throws -> MTLLibrary {
        if self.libraryCache[bundle] == nil {
            self.libraryCache[bundle] = try self.device.makeDefaultLibrary(bundle: bundle)
        }
        return self.libraryCache[bundle]!
    }

    /// Purges the library cache, removing all cached libraries.
    ///
    /// This method clears the internal library cache, forcing the libraries to be reloaded when requested again.
    public func purgeLibraryCache() {
        self.libraryCache = [:]
    }
}
