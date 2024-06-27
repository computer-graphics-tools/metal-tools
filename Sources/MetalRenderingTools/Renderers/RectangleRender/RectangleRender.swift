import Metal
import CoreGraphics
import CoreImage

/// A class for rendering rectangles using Metal.
final public class RectangleRender {

    /// A descriptor for the geometry of a rectangle.
    final public class GeometryDescriptor {
        /// The color of the rectangle.
        public let color: SIMD4<Float>

        /// The normalized rectangle defining the bounds of the rectangle.
        public let normalizedRect: SIMD4<Float>

        /// Initializes a new `GeometryDescriptor` with the specified color and normalized rectangle.
        ///
        /// - Parameters:
        ///   - color: The color of the rectangle.
        ///   - normalizedRect: The normalized rectangle defining the bounds of the rectangle.
        ///
        /// This initializer sets the color and normalized rectangle for the `GeometryDescriptor`.
        public init(
            color: SIMD4<Float>,
            normalizedRect: SIMD4<Float>
        ) {
            self.color = color
            self.normalizedRect = normalizedRect
        }

        /// Convenience initializer for creating a `GeometryDescriptor` from `CGColor` and `CGRect`.
        ///
        /// - Parameters:
        ///   - color: The color of the rectangle as a `CGColor`.
        ///   - normalizedRect: The normalized rectangle defining the bounds of the rectangle as a `CGRect`.
        ///
        /// This initializer converts the `CGColor` and `CGRect` to the appropriate formats and initializes the `GeometryDescriptor`.
        public convenience init(
            color: CGColor,
            normalizedRect: CGRect
        ) {
            let normalizedRect = SIMD4<Float>(
                .init(normalizedRect.origin.x),
                .init(normalizedRect.origin.y),
                .init(normalizedRect.size.width),
                .init(normalizedRect.size.height)
            )
            let ciColor = CIColor(cgColor: color)
            let color = SIMD4<Float>(
                .init(ciColor.red),
                .init(ciColor.green),
                .init(ciColor.blue),
                .init(ciColor.alpha)
            )
            self.init(
                color: color,
                normalizedRect: normalizedRect
            )
        }
    }

    // MARK: - Properties

    /// The array of geometry descriptors for the rectangles.
    public var geometryDescriptors: [GeometryDescriptor] = [] {
        didSet { self.updateGeometry() }
    }

    /// The array of rectangles to be rendered.
    private var rectangles: [Rectangle] = []

    /// The render pipeline state for rendering rectangles.
    private let renderPipelineState: MTLRenderPipelineState

    // MARK: - Life Cycle

    /// Creates a new instance of `RectangleRender`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
    ///
    /// This initializer sets up the render pipeline state and prepares the renderer for rendering rectangles.
    public convenience init(
        context: MTLContext,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        try self.init(
            library: context.library(for: Self.self),
            pixelFormat: pixelFormat
        )
    }

    /// Creates a new instance of `RectangleRender` with the specified library and pixel format.
    ///
    /// - Parameters:
    ///   - library: Metal library.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
    ///
    /// This initializer sets up the render pipeline state for the `RectangleRender`.
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

        self.renderPipelineState = try library.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }

    // MARK: - Helpers

    /// Updates the geometry for the rectangles based on the current descriptors.
    ///
    /// This method updates the geometry for the rectangles by processing the descriptors.
    private func updateGeometry() {
        self.rectangles.removeAll()
        self.geometryDescriptors.forEach { descriptor in
            let originX = descriptor.normalizedRect.x
            let originY = descriptor.normalizedRect.y
            let width = descriptor.normalizedRect.z
            let height = descriptor.normalizedRect.w
            let topLeftPosition = SIMD2<Float>(originX, originY)
            let bottomLeftPosition = SIMD2<Float>(originX, originY + height)
            let topRightPosition = SIMD2<Float>(originX + width, originY)
            let bottomRightPosition = SIMD2<Float>(originX + width, originY + height)
            let rect = Rectangle(
                topLeft: topLeftPosition,
                bottomLeft: bottomLeftPosition,
                topRight: topRightPosition,
                bottomRight: bottomRightPosition
            )
            self.rectangles.append(rect)
        }
    }

    // MARK: - Rendering

    /// Render a rectangle in a target texture.
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

    /// Render a rectangle in a target texture.
    ///
    /// - Parameter renderEncoder: Container to put the rendering work into.
    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        guard !self.rectangles.isEmpty
        else { return }

        #if DEBUG
        renderEncoder.pushDebugGroup("Draw Rectangle Geometry")
        #endif
        self.rectangles.enumerated().forEach { index, rectangle in
            let rectangle = self.rectangles[index]
            let color = self.geometryDescriptors[index].color

            renderEncoder.setRenderPipelineState(self.renderPipelineState)
            renderEncoder.set(
                vertexValue: rectangle,
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

    public static let vertexFunctionName = "rectVertex"
    public static let fragmentFunctionName = "rectFragment"
}
