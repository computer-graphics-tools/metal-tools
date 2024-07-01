import MetalTools

/// A class that performs texture copy operations using Metal.
final public class TextureCopy {
    // MARK: - Properties

    /// The compute pipeline state used for the texture copy operation.
    public let pipelineState: MTLComputePipelineState

    /// Indicates whether the device supports non-uniform threadgroups.
    private let deviceSupportsNonuniformThreadgroups: Bool

    // MARK: - Life Cycle

    /// Initializes a new instance of `TextureCopy` using a Metal context.
    ///
    /// - Parameters:
    ///   - context: The Metal context to use.
    ///   - scalarType: The scalar type for the computation. Defaults to `.half`.
    /// - Throws: An error if the initialization fails.
    public convenience init(
        context: MTLContext,
        scalarType: MTLPixelFormat.ScalarType = .half
    ) throws {
        try self.init(
            library: context.library(for: .module),
            scalarType: scalarType
        )
    }

    /// Initializes a new instance of `TextureCopy` using a Metal library.
    ///
    /// - Parameters:
    ///   - library: The Metal library containing the kernel functions.
    ///   - scalarType: The scalar type for the computation. Defaults to `.half`.
    /// - Throws: An error if the initialization fails.
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

    /// Encodes a full texture copy operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to encode into.
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

    /// Encodes a full texture copy operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use.
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

    /// Encodes a partial texture copy operation into a command buffer.
    ///
    /// - Parameters:
    ///   - sourceTexureRegion: The region of the source texture to copy.
    ///   - source: The source texture.
    ///   - destinationTextureOrigin: The origin in the destination texture to copy to.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to encode into.
    public func callAsFunction(
        region sourceTexureRegion: MTLRegion,
        from source: MTLTexture,
        to destinationTextureOrigin: MTLOrigin,
        of destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        self.copy(
            region: sourceTexureRegion,
            from: source,
            to: destinationTextureOrigin,
            of: destination,
            in: commandBuffer
        )
    }

    /// Encodes a partial texture copy operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - sourceTexureRegion: The region of the source texture to copy.
    ///   - source: The source texture.
    ///   - destinationTextureOrigin: The origin in the destination texture to copy to.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use.
    public func callAsFunction(
        region sourceTexureRegion: MTLRegion,
        from source: MTLTexture,
        to destinationTextureOrigin: MTLOrigin,
        of destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.copy(
            region: sourceTexureRegion,
            from: source,
            to: destinationTextureOrigin,
            of: destination,
            using: encoder
        )
    }

    /// Encodes a full texture copy operation into a command buffer.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to encode into.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Copy"
            self.encode(
                source: source,
                destination: destination,
                using: encoder
            )
        }
    }

    /// Encodes a full texture copy operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - source: The source texture.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use.
    public func encode(
        source: MTLTexture,
        destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        self.copy(
            region: source.region,
            from: source,
            to: .zero,
            of: destination,
            using: encoder
        )
    }

    /// Encodes a partial texture copy operation into a command buffer.
    ///
    /// - Parameters:
    ///   - sourceTexureRegion: The region of the source texture to copy.
    ///   - source: The source texture.
    ///   - destinationTextureOrigin: The origin in the destination texture to copy to.
    ///   - destination: The destination texture.
    ///   - commandBuffer: The command buffer to encode into.
    public func copy(
        region sourceTexureRegion: MTLRegion,
        from source: MTLTexture,
        to destinationTextureOrigin: MTLOrigin,
        of destination: MTLTexture,
        in commandBuffer: MTLCommandBuffer
    ) {
        commandBuffer.compute { encoder in
            encoder.label = "Texture Copy"
            self.copy(
                region: sourceTexureRegion,
                from: source,
                to: destinationTextureOrigin,
                of: destination,
                using: encoder
            )
        }
    }

    /// Encodes a partial texture copy operation using a compute command encoder.
    ///
    /// - Parameters:
    ///   - sourceTexureRegion: The region of the source texture to copy.
    ///   - source: The source texture.
    ///   - destinationTextureOrigin: The origin in the destination texture to copy to.
    ///   - destination: The destination texture.
    ///   - encoder: The compute command encoder to use.
    public func copy(
        region sourceTexureRegion: MTLRegion,
        from source: MTLTexture,
        to destinationTextureOrigin: MTLOrigin,
        of destination: MTLTexture,
        using encoder: MTLComputeCommandEncoder
    ) {
        // 1. Calculate read origin correction.
        let readOriginCorrection = MTLOrigin(
            x: abs(min(0, sourceTexureRegion.origin.x)),
            y: abs(min(0, sourceTexureRegion.origin.y)),
            z: 0
        )

        // 2. Clamp read region to read texture.
        guard var readRegion = sourceTexureRegion.clamped(to: source.region)
        else {
            #if DEBUG
            print("Read region is less or outside of source texture.")
            #endif
            return
        }

        // 3. Write origin correction.
        var writeOrigin = MTLOrigin(
            x: destinationTextureOrigin.x + readOriginCorrection.x,
            y: destinationTextureOrigin.y + readOriginCorrection.y,
            z: 0
        )

        // 4. Calculate destination origin correction.
        let writeOriginCorrection = MTLOrigin(
            x: abs(min(0, writeOrigin.x)),
            y: abs(min(0, writeOrigin.y)),
            z: 0
        )

        // 5. Clamp origin destination.
        readRegion.origin.x += writeOriginCorrection.x
        readRegion.origin.y += writeOriginCorrection.x
        readRegion.size.width -= writeOriginCorrection.x
        readRegion.size.height -= writeOriginCorrection.y

        // 6. Clamp destination origin by destination texture.
        writeOrigin.x = max(0, writeOrigin.x)
        writeOrigin.y = max(0, writeOrigin.y)

        // 7. Calculate grid size.
        let gridSize = MTLSize(
            width: min(
                readRegion.size.width,
                destination.width - writeOrigin.x
            ),
            height: min(
                readRegion.size.height,
                destination.height - writeOrigin.y
            ),
            depth: 1
        )

        guard gridSize.width > 0,
              gridSize.height > 0
        else {
            #if DEBUG
            print("Grid size is less or equal to zero.")
            #endif
            return
        }

        let readOffset = SIMD2<Int16>(
            x: .init(readRegion.origin.x),
            y: .init(readRegion.origin.y)
        )
        let writeOffset = SIMD2<Int16>(
            x: .init(writeOrigin.x),
            y: .init(writeOrigin.y)
        )

        encoder.setTextures(source, destination)
        encoder.setValue(
            readOffset,
            at: 0
        )
        encoder.setValue(
            writeOffset,
            at: 1
        )

        if self.deviceSupportsNonuniformThreadgroups {
            encoder.dispatch2d(
                state: self.pipelineState,
                exactly: gridSize
            )
        } else {
            encoder.setValue(
                SIMD2<UInt16>(
                    x: .init(gridSize.width),
                    y: .init(gridSize.height)
                ),
                at: 2
            )
            encoder.dispatch2d(
                state: self.pipelineState,
                covering: gridSize
            )
        }
    }

    /// The name of the Metal kernel function used for texture copying.
    public static let functionName = "textureCopy"
}
