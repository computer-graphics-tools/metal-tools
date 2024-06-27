import MetalTools
import Metal

/// A class for rendering points using Metal.
final public class PointsRender {
    // MARK: - Properties

    /// Point positions described in a normalized coordinate system.
    public var pointsPositions: [SIMD2<Float>] {
        set {
            self.pointCount = newValue.count
            self.pointsPositionsBuffer = try? self.renderPipelineState
                .device
                .buffer(
                    with: newValue,
                    options: .storageModeShared
                )
        }
        get {
            if let pointsPositionsBuffer = self.pointsPositionsBuffer,
               let pointsPositions = pointsPositionsBuffer.array(
                   of: SIMD2<Float>.self,
                   count: self.pointCount
               )
            {
                return pointsPositions
            } else {
                return []
            }
        }
    }

    /// Point color. Red is default.
    public var color: SIMD4<Float> = .init(1, 0, 0, 1)

    /// Point size in pixels. Default is 40.
    public var pointSize: Float = 40

    /// The buffer containing the point positions.
    private var pointsPositionsBuffer: MTLBuffer?

    /// The number of points to render.
    private var pointCount: Int = 0

    /// The render pipeline state for rendering points.
    private let renderPipelineState: MTLRenderPipelineState

    // MARK: - Life Cycle

    /// Creates a new instance of `PointsRender`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - pixelFormat: Color attachment's pixel format.
    ///
    /// This initializer sets up the render pipeline state and prepares the renderer for rendering points.
    public convenience init(
        context: MTLContext,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        try self.init(
            library: context.library(for: Self.self),
            pixelFormat: pixelFormat
        )
    }

    /// Creates a new instance of `PointsRender`.
    ///
    /// - Parameters:
    ///   - library: Shader library.
    ///   - pixelFormat: Color attachment's pixel format.
    ///
    /// This initializer sets up the render pipeline state and prepares the renderer for rendering points
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

        self.renderPipelineState = try library.device.makeRenderPipelineState(
            descriptor: renderPipelineDescriptor
        )
    }

    // MARK: - Rendering

    /// Renders the points using the specified render pass descriptor and command buffer.
    ///
    /// - Parameters:
    ///   - renderPassDescriptor: The descriptor for the render pass.
    ///   - commandBuffer: The command buffer to use for rendering.
    /// - Throws: An error if rendering fails.
    ///
    /// This method sets the render target size and executes the rendering commands.
    public func render(
        renderPassDescriptor: MTLRenderPassDescriptor,
        commandBuffer: MTLCommandBuffer
    ) throws {
        commandBuffer.render(
            descriptor: renderPassDescriptor,
            self.render(using:)
        )
    }

    /// Render points in a target texture.
    ///
    /// - Parameter renderEncoder: Container to put the rendering work into.
    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        guard self.pointCount != 0 else { return }

        // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool.
        renderEncoder.pushDebugGroup("Draw Points Geometry")
        // Set render command encoder state.
        renderEncoder.setRenderPipelineState(self.renderPipelineState)
        // Set any buffers fed into our render pipeline.
        renderEncoder.setVertexBuffer(
            self.pointsPositionsBuffer,
            offset: 0,
            index: 0
        )
        renderEncoder.set(
            vertexValue: self.pointSize,
            at: 1
        )
        renderEncoder.set(
            fragmentValue: self.color,
            at: 0
        )
        // Draw.
        renderEncoder.drawPrimitives(
            type: .point,
            vertexStart: 0,
            vertexCount: 1,
            instanceCount: self.pointCount
        )
        renderEncoder.popDebugGroup()
    }

    private static let vertexFunctionName = "pointVertex"
    private static let fragmentFunctionName = "pointFragment"
}
