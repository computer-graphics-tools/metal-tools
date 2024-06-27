import Metal

public extension MTLFunctionConstantValues {
    // MARK: - Generic

    /// Sets a single value of any type as a function constant.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - type: The Metal data type of the value.
    ///   - index: The index of the constant.
    func set<T>(
        _ value: T,
        type: MTLDataType,
        at index: Int
    ) {
        withUnsafePointer(to: value) {
            self.setConstantValue(
                $0,
                type: type,
                index: index
            )
        }
    }

    /// Sets an array of values of any type as function constants.
    ///
    /// - Parameters:
    ///   - values: The array of values to set.
    ///   - type: The Metal data type of the values.
    ///   - startIndex: The starting index for setting the constants (default is 0).
    func set<T>(
        _ values: [T],
        type: MTLDataType,
        startingAt startIndex: Int = 0
    ) {
        withUnsafePointer(to: values) {
            self.setConstantValues(
                $0,
                type: type,
                range: startIndex ..< (startIndex + values.count)
            )
        }
    }

    // MARK: - Bool

    /// Sets a boolean value as a function constant.
    ///
    /// - Parameters:
    ///   - value: The boolean value to set.
    ///   - index: The index of the constant.
    func set(
        _ value: Bool,
        at index: Int
    ) {
        self.set(
            value,
            type: .bool,
            at: index
        )
    }

    /// Sets an array of boolean values as function constants.
    ///
    /// - Parameters:
    ///   - values: The array of boolean values to set.
    ///   - startIndex: The starting index for setting the constants (default is 0).
    func set(
        _ values: [Bool],
        startingAt startIndex: Int = 0
    ) {
        self.set(
            values,
            type: .bool,
            startingAt: startIndex
        )
    }

    // MARK: - Float

    /// Sets a float value as a function constant.
    ///
    /// - Parameters:
    ///   - value: The float value to set.
    ///   - index: The index of the constant.
    func set(
        _ value: Float,
        at index: Int
    ) {
        self.set(
            value,
            type: .float,
            at: index
        )
    }

    /// Sets an array of float values as function constants.
    ///
    /// - Parameters:
    ///   - values: The array of float values to set.
    ///   - startIndex: The starting index for setting the constants (default is 0).
    func set(
        _ values: [Float],
        startingAt startIndex: Int = 0
    ) {
        self.set(
            values,
            type: .float,
            startingAt: startIndex
        )
    }

    // MARK: - Int32

    /// Sets an Int32 value as a function constant.
    ///
    /// - Parameters:
    ///   - value: The Int32 value to set.
    ///   - index: The index of the constant.
    func set(
        _ value: Int32,
        at index: Int
    ) {
        self.set(
            value,
            type: .int,
            at: index
        )
    }

    /// Sets an array of Int32 values as function constants.
    ///
    /// - Parameters:
    ///   - values: The array of Int32 values to set.
    ///   - startIndex: The starting index for setting the constants (default is 0).
    func set(
        _ values: [Int32],
        startingAt startIndex: Int = 0
    ) {
        self.set(
            values,
            type: .int,
            startingAt: startIndex
        )
    }

    // MARK: - Int

    /// Sets an Int value as a function constant.
    ///
    /// - Parameters:
    ///   - value: The Int value to set.
    ///   - index: The index of the constant.
    func set(
        _ value: Int,
        at index: Int
    ) {
        self.set(
            Int32(value),
            at: index
        )
    }

    /// Sets an array of Int values as function constants.
    ///
    /// - Parameters:
    ///   - values: The array of Int values to set.
    ///   - startIndex: The starting index for setting the constants (default is 0).
    func set(
        _ values: [Int],
        startingAt startIndex: Int = 0
    ) {
        self.set(
            values.map { Int32($0) },
            startingAt: startIndex
        )
    }

    // MARK: - UInt32

    /// Sets a UInt32 value as a function constant.
    ///
    /// - Parameters:
    ///   - value: The UInt32 value to set.
    ///   - index: The index of the constant.
    func set(
        _ value: UInt32,
        at index: Int
    ) {
        self.set(
            value,
            type: .uint,
            at: index
        )
    }

    /// Sets a SIMD4<UInt32> value as a function constant.
    ///
    /// - Parameters:
    ///   - value: The SIMD4<UInt32> value to set.
    ///   - index: The index of the constant.
    func set(
        _ value: SIMD4<UInt32>,
        at index: Int
    ) {
        self.set(
            value,
            type: .uint4,
            at: index
        )
    }

    /// Sets an array of UInt32 values as function constants.
    ///
    /// - Parameters:
    ///   - values: The array of UInt32 values to set.
    ///   - startIndex: The starting index for setting the constants (default is 0).
    func set(
        _ values: [UInt32],
        startingAt startIndex: Int = 0
    ) {
        self.set(
            values,
            type: .uint,
            startingAt: startIndex
        )
    }

    // MARK: - UInt

    /// Sets a UInt value as a function constant.
    ///
    /// - Parameters:
    ///   - value: The UInt value to set.
    ///   - index: The index of the constant.
    func set(
        _ value: UInt,
        at index: Int
    ) {
        self.set(
            UInt32(value),
            at: index
        )
    }

    /// Sets an array of UInt values as function constants.
    ///
    /// - Parameters:
    ///   - values: The array of UInt values to set.
    ///   - startIndex: The starting index for setting the constants (default is 0).
    func set(
        _ values: [UInt],
        startingAt startIndex: Int = 0
    ) {
        self.set(
            values.map { UInt32($0) },
            startingAt: startIndex
        )
    }
}
