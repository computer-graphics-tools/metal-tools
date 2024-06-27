import MetalTools
import Metal

extension BitonicSort {
    /// Represents the general pass of the Bitonic Sort algorithm.
    final class GeneralPass {
        // MARK: - Properties

        /// The compute pipeline state for this pass.
        let pipelineState: MTLComputePipelineState

        /// Indicates whether the device supports non-uniform threadgroups.
        private let deviceSupportsNonuniformThreadgroups: Bool

        // MARK: - Initialization

        /// Initializes a new GeneralPass instance using a Metal context.
        ///
        /// - Parameters:
        ///   - context: The Metal context to use.
        ///   - scalarType: The scalar type of the data to be sorted.
        /// - Throws: An error if initialization fails.
        convenience init(
            context: MTLContext,
            scalarType: MTLPixelFormat.ScalarType
        ) throws {
            try self.init(
                library: context.library(for: .module),
                scalarType: scalarType
            )
        }

        /// Initializes a new GeneralPass instance using a Metal library.
        ///
        /// - Parameters:
        ///   - library: The Metal library containing the required kernel functions.
        ///   - scalarType: The scalar type of the data to be sorted.
        /// - Throws: An error if initialization fails.
        init(
            library: MTLLibrary,
            scalarType: MTLPixelFormat.ScalarType
        ) throws {
            self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)

            let constantValues = MTLFunctionConstantValues()
            constantValues.set(
                self.deviceSupportsNonuniformThreadgroups,
                at: 0
            )

            let `extension` = "_" + scalarType.rawValue
            self.pipelineState = try library.computePipelineState(
                function: "bitonicSortGeneralPass" + `extension`,
                constants: constantValues
            )
        }

        // MARK: - Encoding

        /// Encodes the general pass of the sorting operation into a command buffer.
        ///
        /// - Parameters:
        ///   - data: The buffer containing the data to be sorted.
        ///   - params: Parameters for the sorting operation.
        ///   - gridSize: The size of the compute grid.
        ///   - unitSize: The size of each unit in the grid.
        ///   - commandBuffer: The command buffer to encode into.
        func callAsFunction(
            data: MTLBuffer,
            params: SIMD2<UInt32>,
            gridSize: Int,
            unitSize: Int,
            in commandBuffer: MTLCommandBuffer
        ) {
            self.encode(
                data: data,
                params: params,
                gridSize: gridSize,
                unitSize: unitSize,
                in: commandBuffer
            )
        }

        /// Encodes the general pass of the sorting operation using a compute command encoder.
        ///
        /// - Parameters:
        ///   - data: The buffer containing the data to be sorted.
        ///   - params: Parameters for the sorting operation.
        ///   - gridSize: The size of the compute grid.
        ///   - unitSize: The size of each unit in the grid.
        ///   - encoder: The compute command encoder to use.
        func callAsFunction(
            data: MTLBuffer,
            params: SIMD2<UInt32>,
            gridSize: Int,
            unitSize: Int,
            using encoder: MTLComputeCommandEncoder
        ) {
            self.encode(
                data: data,
                params: params,
                gridSize: gridSize,
                unitSize: unitSize,
                using: encoder
            )
        }

        /// Encodes the general pass of the sorting operation into a command buffer.
        ///
        /// - Parameters:
        ///   - data: The buffer containing the data to be sorted.
        ///   - params: Parameters for the sorting operation.
        ///   - gridSize: The size of the compute grid.
        ///   - unitSize: The size of each unit in the grid.
        ///   - commandBuffer: The command buffer to encode into.
        func encode(
            data: MTLBuffer,
            params: SIMD2<UInt32>,
            gridSize: Int,
            unitSize: Int,
            in commandBuffer: MTLCommandBuffer
        ) {
            commandBuffer.compute { encoder in
                encoder.label = "Bitonic Sort General Pass"
                self.encode(
                    data: data,
                    params: params,
                    gridSize: gridSize,
                    unitSize: unitSize,
                    using: encoder
                )
            }
        }

        /// Encodes the general pass of the sorting operation using a compute command encoder.
        ///
        /// - Parameters:
        ///   - data: The buffer containing the data to be sorted.
        ///   - params: Parameters for the sorting operation.
        ///   - gridSize: The size of the compute grid.
        ///   - unitSize: The size of each unit in the grid.
        ///   - encoder: The compute command encoder to use.
        func encode(
            data: MTLBuffer,
            params: SIMD2<UInt32>,
            gridSize: Int,
            unitSize: Int,
            using encoder: MTLComputeCommandEncoder
        ) {
            encoder.setBuffers(data)
            encoder.setValue(UInt32(gridSize), at: 1)
            encoder.setValue(params, at: 2)

            if self.deviceSupportsNonuniformThreadgroups {
                encoder.dispatch1d(
                    state: self.pipelineState,
                    exactly: gridSize,
                    threadgroupWidth: unitSize
                )
            } else {
                encoder.dispatch1d(
                    state: self.pipelineState,
                    covering: gridSize,
                    threadgroupWidth: unitSize
                )
            }
        }
    }
}
