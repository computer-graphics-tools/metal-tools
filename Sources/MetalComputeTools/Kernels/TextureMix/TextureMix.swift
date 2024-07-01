import MetalTools
import SIMDTools
import simd

/// A class for performing texture mixing using Metal.
final public class TextureMix {

    // MARK: - Type Definitions

    /// Configuration structure for texture mixing.
    public struct Configuration: Equatable {
        /// Enum representing the position type.
        public enum Position: Equatable {
            case normalized(SIMD2<Float>),
                 pixel(SIMD2<UInt>)

            public static let `default` = Position.normalized(.init(repeating: 0.5))
        }

        /// Enum representing the scale type.
        public enum Scale: Equatable {
            case aspectFill,
                 aspectFit,
                 fill,
                 arbitrary(SIMD2<Float>)

            public static let `default` = Scale.fill
        }

        /// Structure representing the rotation angles.
        public struct Rotation: Equatable {
            public var x: Angle
            public var y: Angle

            /// Initializes a new instance of `Rotation`.
            ///
            /// - Parameters:
            ///   - rotationX: The rotation angle around the X-axis.
            ///   - rotationY: The rotation angle around the Y-axis.
            public init(
                rotationX: Angle,
                rotationY: Angle
            ) {
                self.x = rotationX
                self.y = rotationY
            }

            /// Initializes a new instance of `Rotation` with the same angle for both axes.
            ///
            /// - Parameter angle: The rotation angle for both axes.
            public init(repeating angle: Angle) {
                self.x = angle
                self.y = angle
            }
        }

        public var position: Position
        public var anchorPoint: SIMD2<Float>
        public var rotation: Rotation
        public var scale: Scale
        public var opacity: Float

        /// Initializes a new instance of `Configuration`.
        ///
        /// - Parameters:
        ///   - position: The position type. Defaults to `.default`.
        ///   - anchorPoint: The anchor point. Defaults to `(0.5, 0.5)`.
        ///   - rotation: The rotation configuration. Defaults to `.init(repeating: .zero)`.
        ///   - scale: The scale type. Defaults to `.default`.
        ///   - opacity: The opacity value. Defaults to `1.0`.
        public init(
            position: Position = .default,
            anchorPoint: SIMD2<Float> = .init(repeating: 0.5),
            rotation: Rotation = .init(repeating: .zero),
            scale: Scale = .default,
            opacity: Float = 1.0
        ) {
            self.position = position
            self.anchorPoint = anchorPoint
            self.rotation = rotation
            self.scale = scale
            self.opacity = opacity
        }

        public static let `default` = Configuration()
    }

    // MARK: - Private Properties

    private let pipelineState: MTLComputePipelineState
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Init

    /// Creates a new instance of `TextureMix`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the texture mix operation with the specified context.
    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    /// Creates a new instance of `TextureMix` with the specified library.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for the texture mix operation.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the pipeline state for the texture mix operation.
    public init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device.supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(
            self.deviceSupportsNonuniformThreadgroups,
            at: 0
        )
        self.pipelineState = try library.computePipelineState(
            function: Self.functionName,
            constants: constantValues
        )
    }

    // MARK: - Encode

    /// Encodes the texture mix operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - configuration: The configuration for the mix operation. Defaults to `.default`.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the mix operation using the provided textures, configuration, and command buffer.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        configuration: Configuration = .default,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            configuration: configuration,
            in: commandBuffer
        )
    }

    /// Encodes the texture mix operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - configuration: The configuration for the mix operation. Defaults to `.default`.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the mix operation using the provided textures, configuration, and command encoder.
    public func callAsFunction(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        configuration: Configuration = .default,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.encode(
            sourceOne: sourceOne,
            sourceTwo: sourceTwo,
            destination: destination,
            configuration: configuration,
            using: encoder
        )
    }

    /// Encodes the texture mix operation using the specified command buffer.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - configuration: The configuration for the mix operation. Defaults to `.default`.
    ///   - commandBuffer: The command buffer to use for encoding the operation.
    ///
    /// This method encodes the mix operation using the provided textures, configuration, and command buffer.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        configuration: Configuration = .default,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "TextureMix"
            self.encode(
                sourceOne: sourceOne,
                sourceTwo: sourceTwo,
                destination: destination,
                configuration: configuration,
                using: encoder
            )
        }
    }

    /// Encodes the texture mix operation using the specified command encoder.
    ///
    /// - Parameters:
    ///   - sourceOne: The first source texture.
    ///   - sourceTwo: The second source texture.
    ///   - destination: The destination texture.
    ///   - configuration: The configuration for the mix operation. Defaults to `.default`.
    ///   - encoder: The compute command encoder to use for encoding the operation.
    ///
    /// This method encodes the mix operation using the provided textures, configuration, and command encoder.
    public func encode(
        sourceOne: MTLTexture,
        sourceTwo: MTLTexture,
        destination: MTLTexture,
        configuration: Configuration = .default,
        using encoder: MTLComputeCommandEncoder
    ) {
        let transform = self.transform(
            sourceOneSize: .init(
                x: .init(sourceOne.width),
                y: .init(sourceOne.height)
            ),
            sourceTwoSize: .init(
                x: .init(sourceTwo.width),
                y: .init(sourceTwo.height)
            ),
            configuration: configuration
        )

        encoder.setTextures(sourceOne, sourceTwo, destination)
        encoder.setValue(transform, at: 0)
        encoder.setValue(configuration.opacity, at: 1)

        let threadgroupSize = self.pipelineState.max2dThreadgroupSize
        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(
                state: self.pipelineState,
                exactly: destination.size,
                threadgroupSize: threadgroupSize
            )
        } else {
            encoder.dispatch2d(
                state: self.pipelineState,
                covering: destination.size,
                threadgroupSize: threadgroupSize
            )
        }
    }

    // MARK: - Private

    /// Computes the transformation matrix for the mix operation based on the provided configuration.
    ///
    /// - Parameters:
    ///   - sourceOneSize: The size of the first source texture.
    ///   - sourceTwoSize: The size of the second source texture.
    ///   - configuration: The configuration for the mix operation.
    /// - Returns: The transformation matrix.
    private func transform(
        sourceOneSize: SIMD2<Float>,
        sourceTwoSize: SIMD2<Float>,
        configuration: Configuration
    ) -> simd_float3x3 {
        // We assume that the anchor point of sourceTwo is its coordinate system start, like in CALayers,
        // so we don't do pre-translation, only post-translation.
        let preTranslationValue = SIMD2<Float>(
            configuration.anchorPoint.x * sourceTwoSize.x,
            configuration.anchorPoint.y * sourceTwoSize.y
        )
        let postTranslationValue = -preTranslationValue
        let postTranslation = float3x3.translate(value: postTranslationValue)

        let scale: float3x3
        switch configuration.scale {
        case let .arbitrary(scaleValue):
            scale = .scale(value: scaleValue)
        case .aspectFit:
            scale = .aspectFitScale(
                originalSize: sourceTwoSize,
                boundingSize: sourceOneSize
            )
        case .aspectFill:
            scale = .aspectFillScale(
                originalSize: sourceTwoSize,
                boundingSize: sourceOneSize
            )
        case .fill:
            scale = .fillScale(
                originalSize: sourceTwoSize,
                boundingSize: sourceOneSize
            )
        }

        let rotationX = tan(-configuration.rotation.x.radians / 2.0)
        let rotationY = -sin(-configuration.rotation.y.radians)
        let rotation: float3x3 = .shear(x: rotationX) * .shear(y: rotationY) * .shear(x: rotationX)

        let translation: float3x3
        switch configuration.position {
        case let .normalized(translationValue):
            translation = .translate(value: translationValue * sourceOneSize)
        case let .pixel(translationValue):
            translation = .translate(value: SIMD2<Float32>(translationValue))
        }

        let transform: float3x3 = translation * rotation * scale * postTranslation

        return transform.inverse
    }

    /// The name of the Metal function used for texture mixing.
    public static let functionName = "textureMix"
}
