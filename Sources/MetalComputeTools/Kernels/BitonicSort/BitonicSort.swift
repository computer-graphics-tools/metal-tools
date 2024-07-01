import MetalTools

/// A class that implements the Bitonic Sort algorithm using Metal.
final public class BitonicSort {
    // MARK: - Properties

    private let firstPass: FirstPass
    private let generalPass: GeneralPass
    private let finalPass: FinalPass

    // MARK: - Initialization

    /// Initializes a new BitonicSort instance using a Metal context.
    ///
    /// - Parameters:
    ///   - context: The Metal context to use.
    ///   - scalarType: The scalar type of the data to be sorted.
    /// - Throws: An error if initialization fails.
    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Initializes a new BitonicSort instance using a Metal library.
    ///
    /// - Parameters:
    ///   - library: The Metal library containing the required kernel functions.
    ///   - scalarType: The scalar type of the data to be sorted.
    /// - Throws: An error if initialization fails.
    public init(
        library: MTLLibrary,
        scalarType: MTLPixelFormat.ScalarType
    ) throws {
        self.firstPass = try .init(
            library: library,
            scalarType: scalarType
        )
        self.generalPass = try .init(
            library: library,
            scalarType: scalarType
        )
        self.finalPass = try .init(
            library: library,
            scalarType: scalarType
        )
    }

    // MARK: - Encoding

    /// Encodes the sorting operation into a command buffer.
    ///
    /// - Parameters:
    ///   - data: The buffer containing the data to be sorted.
    ///   - count: The number of elements to sort.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        data: MTLBuffer,
        count: Int,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            data: data,
            count: count,
            in: commandBuffer
        )
    }

    /// Encodes the sorting operation into a command buffer.
    ///
    /// - Parameters:
    ///   - data: The buffer containing the data to be sorted.
    ///   - count: The number of elements to sort.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        data: MTLBuffer,
        count: Int,
        in commandBuffer: MTLCommandBuffer
    ) {
        let elementStride = data.length / count
        let gridSize = count >> 1
        let unitSize = min(
            gridSize,
            self.generalPass
                .pipelineState
                .maxTotalThreadsPerThreadgroup
        )

        var params = SIMD2<UInt32>(repeating: 1)

        self.firstPass(
            data: data,
            elementStride: elementStride,
            gridSize: gridSize,
            unitSize: unitSize,
            in: commandBuffer
        )
        params.x = .init(unitSize << 1)

        while params.x < count {
            params.y = params.x
            params.x <<= 1
            repeat {
                if unitSize < params.y {
                    self.generalPass(
                        data: data,
                        params: params,
                        gridSize: gridSize,
                        unitSize: unitSize,
                        in: commandBuffer
                    )
                    params.y >>= 1
                } else {
                    self.finalPass(
                        data: data,
                        elementStride: elementStride,
                        params: params,
                        gridSize: gridSize,
                        unitSize: unitSize,
                        in: commandBuffer
                    )
                    params.y = .zero
                }
            } while params.y > .zero
        }
    }

    public static func buffer<T: FixedWidthInteger>(
        from array: [T],
        device: MTLDevice,
        options: MTLResourceOptions = []
    ) throws -> (buffer: MTLBuffer, paddedCount: Int) {
        return try Self.buffer(
            from: array,
            paddingValue: T.max,
            device: device,
            options: options
        )
    }

    /// Creates a Metal buffer from an array of floating-point values, padding if necessary.
    ///
    /// - Parameters:
    ///   - array: The array of floating-point values to create a buffer from.
    ///   - device: The Metal device to create the buffer on.
    ///   - options: Resource options for the buffer.
    /// - Returns: A tuple containing the created buffer and the padded count.
    /// - Throws: An error if buffer creation fails.
    public static func buffer<T: FloatingPoint>(
        from array: [T],
        device: MTLDevice,
        options: MTLResourceOptions = []
    ) throws -> (buffer: MTLBuffer, paddedCount: Int) {
        return try Self.buffer(
            from: array,
            paddingValue: T.greatestFiniteMagnitude,
            device: device,
            options: options
        )
    }

    // Private helper method for buffer creation
    private static func buffer<T: Numeric>(
        from array: [T],
        paddingValue: T,
        device: MTLDevice,
        options: MTLResourceOptions = []
    ) throws -> (buffer: MTLBuffer, paddedCount: Int) {
        let paddedCount = 1 << UInt(ceil(log2f(.init(array.count))))
        var array = array
        if paddedCount > array.count {
            array += .init(
                repeating: paddingValue,
                count: paddedCount - array.count
            )
        }
        return try (
            buffer: device.buffer(with: array, options: options),
            paddedCount: paddedCount
        )
    }
}
