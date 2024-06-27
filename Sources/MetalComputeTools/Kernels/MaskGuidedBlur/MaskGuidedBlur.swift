import MetalTools
import Metal
import MetalPerformanceShaders

/// A class that applies a mask-guided blur effect to an image using Metal.
final public class MaskGuidedBlur {
    // MARK: - Properties

    /// The compute pipeline state for the row pass of the blur effect.
    public let blurRowPassState: MTLComputePipelineState

    /// The compute pipeline state for the column pass of the blur effect.
    public let blurColumnPassState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `MaskGuidedBlur` using a Metal context.
    ///
    /// - Parameter context: The Metal context to use.
    /// - Throws: An error if the initialization fails.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Initializes a new instance of `MaskGuidedBlur` using a Metal library.
    ///
    /// - Parameter library: The Metal library containing the kernel functions.
    /// - Throws: An error if the initialization fails.
    public init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        self.blurRowPassState = try library.computePipelineState(
            function: Self.blurRowPassFunctionName,
            constants: constantValues
        )
        self.blurColumnPassState = try library.computePipelineState(
            function: Self.blurColumnPassFunctionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the mask-guided blur effect into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - mask: The mask texture guiding the blur effect.
    ///   - destination: The destination texture.
    ///   - sigma: The sigma value controlling the blur intensity.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        source: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        sigma: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            source: source,
            mask: mask,
            destination: destination,
            sigma: sigma,
            in: commandBuffer
        )
    }

    /// Encodes the mask-guided blur effect into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - mask: The mask texture guiding the blur effect.
    ///   - destination: The destination texture.
    ///   - sigma: The sigma value controlling the blur intensity.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        mask: MTLTexture,
        destination: MTLTexture,
        sigma: Float,
        in commandBuffer: MTLCommandBuffer
    ) {
        let temporaryTextureDescriptor = source.descriptor
        temporaryTextureDescriptor.usage = [.shaderRead, .shaderWrite]
        temporaryTextureDescriptor.storageMode = .private
        temporaryTextureDescriptor.pixelFormat = .rgba8Unorm

        commandBuffer.compute { encoder in
            encoder.label = "Mask Guided Blur"
            let temporaryImage = MPSTemporaryImage(
                commandBuffer: commandBuffer,
                textureDescriptor: temporaryTextureDescriptor
            )
            defer { temporaryImage.readCount = 0 }

            encoder.setTextures(source, mask, temporaryImage.texture)
            encoder.setValue(sigma, at: 0)

            if self.deviceSupportsNonuniformThreadgroups {
                encoder.dispatch2d(
                    state: self.blurRowPassState,
                    exactly: source.size
                )
            } else {
                encoder.dispatch2d(
                    state: self.blurRowPassState,
                    covering: source.size
                )
            }

            encoder.setTextures(temporaryImage.texture, mask, destination)
            encoder.setValue(sigma, at: 0)

            if self.deviceSupportsNonuniformThreadgroups {
                encoder.dispatch2d(
                    state: self.blurColumnPassState,
                    exactly: source.size
                )
            } else {
                encoder.dispatch2d(
                    state: self.blurColumnPassState,
                    covering: source.size
                )
            }
        }
    }

    /// The name of the Metal kernel function used for the row pass of the blur effect.
    public static let blurRowPassFunctionName = "maskGuidedBlurRowPass"

    /// The name of the Metal kernel function used for the column pass of the blur effect.
    public static let blurColumnPassFunctionName = "maskGuidedBlurColumnPass"
}
