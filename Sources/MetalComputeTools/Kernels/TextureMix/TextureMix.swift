import MetalTools
import SwiftMath

final public class TextureMix {

    // MARK: - Type Definitions

    public struct Configuration: Equatable {

        public enum Position: Equatable {
            case normalized(SIMD2<Float>),
                 pixel(SIMD2<UInt>)

            public static let `default` = Position.normalized(.init(repeating: 0.5))
        }

        public enum Scale: Equatable {
            case aspectFill,
                 aspectFit,
                 fill,
                 arbitrary(SIMD2<Float>)

            public static let `default` = Scale.fill
        }
        
        public struct Rotation: Equatable {
            public var x: Angle
            public var y: Angle
            
            public init(rotationX: Angle,
                        rotationY: Angle) {
                self.x = rotationX
                self.y = rotationY
            }
            
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

        public init(position: Position = .default,
                    anchorPoint: SIMD2<Float> = .init(repeating: 0.5),
                    rotation: Rotation = .init(repeating: .zero),
                    scale: Scale = .default,
                    opacity: Float = 1.0) {
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

    public convenience init(context: MTLContext) throws {
        try self.init(library: context.library(for: .module))
    }

    public init(library: MTLLibrary) throws {
        self.deviceSupportsNonuniformThreadgroups = library.device
                                                           .supports(feature: .nonUniformThreadgroups)
        let constantValues = MTLFunctionConstantValues()
        constantValues.set(self.deviceSupportsNonuniformThreadgroups,
                           at: 0)
        self.pipelineState = try library.computePipelineState(function: Self.functionName,
                                                              constants: constantValues)
    }
    
    // MARK: - Encode
    
    public func callAsFunction(sourceOne: MTLTexture,
                               sourceTwo: MTLTexture,
                               destination: MTLTexture,
                               configuration: Configuration = .default,
                               in commandBuffer: MTLCommandBuffer) {
        self.encode(sourceOne: sourceOne,
                    sourceTwo: sourceTwo,
                    destination: destination,
                    configuration: configuration,
                    in: commandBuffer)
    }
    
    public func callAsFunction(sourceOne: MTLTexture,
                               sourceTwo: MTLTexture,
                               destination: MTLTexture,
                               configuration: Configuration = .default,
                               using encoder: MTLComputeCommandEncoder) {
        self.encode(sourceOne: sourceOne,
                    sourceTwo: sourceTwo,
                    destination: destination,
                    configuration: configuration,
                    using: encoder)
    }
    
    public func encode(sourceOne: MTLTexture,
                       sourceTwo: MTLTexture,
                       destination: MTLTexture,
                       configuration: Configuration = .default,
                       in commandBuffer: MTLCommandBuffer) {
        commandBuffer.compute { encoder in
            encoder.label = "TextureMix"
            self.encode(sourceOne: sourceOne,
                        sourceTwo: sourceTwo,
                        destination: destination,
                        configuration: configuration,
                        using: encoder)
        }
    }

    public func encode(sourceOne: MTLTexture,
                       sourceTwo: MTLTexture,
                       destination: MTLTexture,
                       configuration: Configuration = .default,
                       using encoder: MTLComputeCommandEncoder) {
        let transform = self.transform(sourceOneSize: .init(x: .init(sourceOne.width),
                                                            y: .init(sourceOne.height)),
                                       sourceTwoSize: .init(x: .init(sourceTwo.width),
                                                            y: .init(sourceTwo.height)),
                                       configuration: configuration)
        
        encoder.setTextures(sourceOne, sourceTwo, destination)
        encoder.setValue(transform, at: 0)
        encoder.setValue(configuration.opacity, at: 1)
        
        let threadgroupSize = self.pipelineState.max2dThreadgroupSize
        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(state: self.pipelineState,
                               exactly: destination.size,
                               threadgroupSize: threadgroupSize)
        }
        else {
            encoder.dispatch2d(state: self.pipelineState,
                               covering: destination.size,
                               threadgroupSize: threadgroupSize)
        }
    }

    // MARK: - Private

    private func transform(sourceOneSize: SIMD2<Float>,
                           sourceTwoSize: SIMD2<Float>,
                           configuration: Configuration) -> simd_float3x3 {
        // We assume that anchor point of sourceTwo is it's coordinate system start, like in CALayers,
        // so we don't do pre-translation, only post-translation.
        let preTranslationValue = SIMD2<Float>(configuration.anchorPoint.x * sourceTwoSize.x,
                                               configuration.anchorPoint.y * sourceTwoSize.y)
        let postTranslationValue = -preTranslationValue
        let postTranslation = Matrix3x3f.translate(tx: postTranslationValue.x,
                                                   ty: postTranslationValue.y)

        let scale: Matrix3x3f
        switch configuration.scale {
        case let .arbitrary(scaleValue):
            scale = .scale(sx: scaleValue.x,
                           sy: scaleValue.y)
        case .aspectFit:
            scale = .aspectFitScale(originalSize: sourceTwoSize,
                                    boundingSize: sourceOneSize)
        case .aspectFill:
            scale = .aspectFillScale(originalSize: sourceTwoSize,
                                     boundingSize: sourceOneSize)
        case .fill:
            scale = .fillScale(originalSize: sourceTwoSize,
                               boundingSize: sourceOneSize)
        }

        let rotationX = tan(-configuration.rotation.x.radians / 2.0)
        let rotationY = -sin(-configuration.rotation.y.radians)
        let rotation: Matrix3x3f = .shear(sx: rotationX)
                                 * .shear(sy: rotationY)
                                 * .shear(sx: rotationX)

        let translation: Matrix3x3f
        switch configuration.position {
        case let .normalized(translationValue):
            translation = .translate(tx: translationValue.x * sourceOneSize.x,
                                     ty: translationValue.y * sourceOneSize.y)
        case let .pixel(translationValue):
            translation = .translate(tx: .init(translationValue.x),
                                     ty: .init(translationValue.y))
        }

        let transform: Matrix3x3f = .identity
                                  * translation
                                  * rotation
                                  * scale
                                  * postTranslation

        return .init(transform.inversed)
    }

    public static let functionName = "textureMix"

}
