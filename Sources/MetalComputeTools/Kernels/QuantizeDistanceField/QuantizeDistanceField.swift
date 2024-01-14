import MetalTools

final public class QuantizeDistanceField {

    // MARK: - Properties

    public let pipelineState: MTLComputePipelineState
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    public init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device
                                                           .supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(self.deviceSupportsNonuniformThreadgroups, at: 0)
        self.pipelineState = try library.computePipelineState(function: Self.functionName,
                                                              constants: constantValues)
    }

    // MARK: - Encode
    
    public func callAsFunction(source: MTLTexture,
                               destination: MTLTexture,
                               normalizationFactor: Float,
                               in commandBuffer: MTLCommandBuffer) {
        self.encode(source: source,
                    destination: destination,
                    normalizationFactor: normalizationFactor,
                    in: commandBuffer)
    }
    
    public func callAsFunction(source: MTLTexture,
                               destination: MTLTexture,
                               normalizationFactor: Float,
                               using encoder: MTLComputeCommandEncoder) {
        self.encode(source: source,
                    destination: destination,
                    normalizationFactor: normalizationFactor,
                    using: encoder)
    }

    public func encode(source: MTLTexture,
                       destination: MTLTexture,
                       normalizationFactor: Float,
                       in commandBuffer: MTLCommandBuffer) {
        commandBuffer.compute { encoder in
            encoder.label = "Quantize Distance Field"
            self.encode(source: source,
                        destination: destination,
                        normalizationFactor: normalizationFactor,
                        using: encoder)
        }
    }

    public func encode(source: MTLTexture,
                       destination: MTLTexture,
                       normalizationFactor: Float,
                       using encoder: MTLComputeCommandEncoder) {
        encoder.setTextures(source, destination)
        encoder.setValue(normalizationFactor, at: 0)
        
        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(state: self.pipelineState,
                               exactly: destination.size)
        } else {
            encoder.dispatch2d(state: self.pipelineState,
                               covering: destination.size)
        }
    }

    public static let functionName = "quantizeDistanceField"
}
