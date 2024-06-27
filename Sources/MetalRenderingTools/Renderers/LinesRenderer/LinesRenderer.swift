import MetalTools
import Metal
import CoreGraphics
import CoreImage

/// A class for rendering lines using Metal.
final public class LinesRender {

    /// A descriptor for the geometry of a line.
    final public class GeometryDescriptor {
        /// The start point of the line.
        public let startPoint: SIMD2<Float>

        /// The end point of the line.
        public let endPoint: SIMD2<Float>

        /// The normalized width of the line.
        public let normalizedWidth: Float

        /// The color of the line.
        public let color: SIMD4<Float>

        /// Initializes a new `GeometryDescriptor` with the specified parameters.
        ///
        /// - Parameters:
        ///   - startPoint: The start point of the line.
        ///   - endPoint: The end point of the line.
        ///   - normalizedWidth: The normalized width of the line.
        ///   - color: The color of the line.
        ///
        /// This initializer sets the start point, end point, normalized width, and color for the `GeometryDescriptor`.
        public init(
            startPoint: SIMD2<Float>,
            endPoint: SIMD2<Float>,
            normalizedWidth: Float,
            color: SIMD4<Float>
        ) {
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.normalizedWidth = normalizedWidth
            self.color = color
        }

        /// Convenience initializer for creating a `GeometryDescriptor` from `CGPoint` and `CGColor`.
        ///
        /// - Parameters:
        ///   - startPoint: The start point of the line as a `CGPoint`.
        ///   - endPoint: The end point of the line as a `CGPoint`.
        ///   - normalizedWidth: The normalized width of the line as a `CGFloat`.
        ///   - color: The color of the line as a `CGColor`.
        ///
        /// This initializer converts the `CGPoint` and `CGColor` to the appropriate formats and initializes the `GeometryDescriptor`.
        public convenience init(
            startPoint: CGPoint,
            endPoint: CGPoint,
            normalizedWidth: CGFloat,
            color: CGColor
        ) {
            let startPoint = SIMD2<Float>(
                .init(startPoint.x),
                .init(startPoint.y)
            )
            let endPoint = SIMD2<Float>(
                .init(endPoint.x),
                .init(endPoint.y)
            )
            let noramlizedWidth = Float(normalizedWidth)
            let ciColor = CIColor(cgColor: color)
            let color = SIMD4<Float>(
                .init(ciColor.red),
                .init(ciColor.green),
                .init(ciColor.blue),
                .init(ciColor.alpha)
            )
            self.init(
                startPoint: startPoint,
                endPoint: endPoint,
                normalizedWidth: noramlizedWidth,
                color: color
            )
        }
    }

    // MARK: - Properties

    /// The array of geometry descriptors for the lines.
    public var geometryDescriptors: [GeometryDescriptor] = [] {
        didSet { self.updateGeometry() }
    }

    /// The array of lines to be rendered.
    private var lines: [Line] = []

    /// The render pipeline state for rendering lines.
    private let renderPipelineState: MTLRenderPipelineState

    // MARK: - Life Cycle

    /// Creates a new instance of `LinesRender`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
    public convenience init(
        context: MTLContext,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        try self.init(
            library: context.library(for: Self.self),
            pixelFormat: pixelFormat
        )
    }

    /// Creates a new instance of LinesRenderer.
    ///
    /// - Parameters:
    ///   - library: Shader library.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Function creation error.
    public init(
        library: MTLLibrary,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        guard let vertexFunction = library.makeFunction(name: Self.vertexFunctionName),
              let fragmentFunction = library.makeFunction(name: Self.fragmentFunctionName)
        else { throw MetalError.MTLLibraryError.functionCreationFailed }

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        renderPipelineDescriptor.colorAttachments[0].setup(blending: .alpha)

        self.renderPipelineState = try library.device
            .makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }

    private func updateGeometry() {
        self.lines = self.geometryDescriptors.map { descriptor in
            .init(
                startPoint: descriptor.startPoint,
                endPoint: descriptor.endPoint,
                width: descriptor.normalizedWidth
            )
        }
    }

    // MARK: - Rendering

    /// Render lines in a target texture.
    ///
    /// - Parameters:
    ///   - renderPassDescriptor: Render pass descriptor to be used.
    ///   - commandBuffer: Command buffer to put the rendering work items into.
    public func render(
        renderPassDescriptor: MTLRenderPassDescriptor,
        commandBuffer: MTLCommandBuffer
    ) throws {
        commandBuffer.render(
            descriptor: renderPassDescriptor,
            self.render(using:)
        )
    }

    /// Render lines in a target texture.
    ///
    /// - Parameter renderEncoder: Container to put the rendering work into.
    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        guard !self.lines.isEmpty else { return }

        #if DEBUG
        renderEncoder.pushDebugGroup("Draw Line Geometry")
        #endif
        self.lines.enumerated().forEach { index, line in
            let color = self.geometryDescriptors[index].color
            renderEncoder.setRenderPipelineState(self.renderPipelineState)
            renderEncoder.set(
                vertexValue: line,
                at: 0
            )
            renderEncoder.set(
                fragmentValue: color,
                at: 0
            )
            renderEncoder.drawPrimitives(
                type: .triangleStrip,
                vertexStart: 0,
                vertexCount: 4
            )
        }
        #if DEBUG
        renderEncoder.popDebugGroup()
        #endif
    }

    public static let vertexFunctionName = "linesVertex"
    public static let fragmentFunctionName = "linesFragment"
}
