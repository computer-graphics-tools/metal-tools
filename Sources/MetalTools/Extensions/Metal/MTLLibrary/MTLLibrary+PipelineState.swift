import Metal

public extension MTLLibrary {
    /// Creates a compute pipeline state for a named function in the library.
    ///
    /// - Parameter functionName: The name of the compute function in the library.
    /// - Returns: A new `MTLComputePipelineState` object.
    /// - Throws: `MetalError.MTLLibraryError.functionCreationFailed` if the function cannot be created,
    ///           or an error if the compute pipeline state creation fails.
    func computePipelineState(function functionName: String) throws -> MTLComputePipelineState {
        guard let function = self.makeFunction(name: functionName)
        else { throw MetalError.MTLLibraryError.functionCreationFailed }
        return try self.device.makeComputePipelineState(function: function)
    }

    /// Creates a compute pipeline state for a named function with constant values in the library.
    ///
    /// - Parameters:
    ///   - function: The name of the compute function in the library.
    ///   - constants: The constant values to be used with the function.
    /// - Returns: A new `MTLComputePipelineState` object.
    /// - Throws: An error if the function cannot be created with the given constants,
    ///           or if the compute pipeline state creation fails.
    func computePipelineState(
        function: String,
        constants: MTLFunctionConstantValues
    ) throws -> MTLComputePipelineState {
        let function = try self.makeFunction(
            name: function,
            constantValues: constants
        )
        return try self.device.makeComputePipelineState(function: function)
    }
}
