import MetalTools

final public class IntegralImage {

    // MARK: - Propertires

    public let pipelineState: MTLComputePipelineState
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    public init(
        library: MTLLibrary,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        let functionName = Self.functionName + "_" + scalarType.rawValue
        self.pipelineState = try library.computePipelineState(
            function: functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            destination: destination,
            in: commandBuffer
        )
    }

    public func callAsFunction(
        source: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            source: source,
            destination: destination,
            using: encoder
        )
    }

    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Integral Image"
            self.encode(
                source: source,
                destination: destination,
                using: encoder
            )
        }
    }

    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encodePass(
            source: source,
            destination: destination,
            isHorisontalPass: true,
            using: encoder
        )
        self.encodePass(
            source: destination,
            destination: destination,
            isHorisontalPass: false,
            using: encoder
        )
    }

    private func encodePass(
        source: MTLTexture,
        destination: MTLTexture,
        isHorisontalPass: Bool,
        using encoder: MTLComputeCommandEncoder
    ) {
        encoder.pushDebugGroup("Integral Image \(isHorisontalPass ? "Horisontal" : "Vertical") Pass")
        defer { encoder.popDebugGroup() }

        encoder.setTextures(source, destination)
        encoder.setValue(isHorisontalPass, at: 0)

        let gridSize = isHorisontalPass ? destination.size.height : destination.size.width

        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch1d(
                state: self.pipelineState,
                exactly: gridSize
            )
        } else {
            encoder.dispatch1d(
                state: self.pipelineState,
                covering: gridSize
            )
        }
    }

    public static let functionName = "integralImage"
}
