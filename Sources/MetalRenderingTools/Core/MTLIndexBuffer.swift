import MetalTools

public class MTLIndexBuffer {

    public let buffer: MTLBuffer
    public let count: Int
    public let type: MTLIndexType

    public init(device: MTLDevice,
                indexArray: [UInt16],
                options: MTLResourceOptions = []) throws {
        self.buffer = try device.buffer(with: indexArray,
                                        options: options)
        self.count = indexArray.count
        self.type = .uint16
    }

    public init(device: MTLDevice,
                indexArray: [UInt32],
                options: MTLResourceOptions = []) throws {
        self.buffer = try device.buffer(with: indexArray,
                                        options: options)
        self.count = indexArray.count
        self.type = .uint32
    }
}
