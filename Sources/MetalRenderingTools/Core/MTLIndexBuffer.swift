import MetalTools
import Metal

/// A class representing an index buffer in Metal.
public class MTLIndexBuffer {
    /// The Metal buffer storing the index data.
    public let buffer: MTLBuffer

    /// The number of indices in the buffer.
    public let count: Int

    /// The type of indices stored in the buffer.
    public let type: MTLIndexType

    /// Initializes a new index buffer with a `UInt16` index array.
    ///
    /// - Parameters:
    ///   - device: The Metal device to use for creating the buffer.
    ///   - indexArray: The array of `UInt16` indices.
    ///   - options: The resource options for the buffer. Defaults to an empty set.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This initializer creates a Metal buffer from a `UInt16` index array.
    public init(
        device: MTLDevice,
        indexArray: [UInt16],
        options: MTLResourceOptions = []
    ) throws {
        self.buffer = try device.buffer(
            with: indexArray,
            options: options
        )
        self.count = indexArray.count
        self.type = .uint16
    }

    /// Initializes a new index buffer with a `UInt32` index array.
    ///
    /// - Parameters:
    ///   - device: The Metal device to use for creating the buffer.
    ///   - indexArray: The array of `UInt32` indices.
    ///   - options: The resource options for the buffer. Defaults to an empty set.
    /// - Throws: An error if the buffer creation fails.
    ///
    /// This initializer creates a Metal buffer from a `UInt32` index array.
    public init(
        device: MTLDevice,
        indexArray: [UInt32],
        options: MTLResourceOptions = []
    ) throws {
        self.buffer = try device.buffer(
            with: indexArray,
            options: options
        )
        self.count = indexArray.count
        self.type = .uint32
    }
}
