import MetalTools
import simd

/// A class for rendering masks using Metal.
public class MaskRenderer {
    // MARK: - Properties

    /// Mask color. Red by default.
    public var color: SIMD4<Float> = .init(1, 0, 0, 0.3)

    /// Texture containing mask information.
    public var maskTexture: MTLTexture? = nil

    /// Rectangle described in a normalized coordinate system.
    public var normalizedRect: CGRect = .zero

    /// The render pipeline state for rendering masks.
    private let renderPipelineState: MTLRenderPipelineState

    // MARK: - Life Cycle

    /// Creates a new instance of `MaskRenderer`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
    ///
    /// This initializer sets up the mask renderer with the specified context and pixel format.
    public convenience init(
        context: MTLContext,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        try self.init(
            library: context.library(for: Self.self),
            pixelFormat: pixelFormat
        )
    }

    /// Creates a new instance of `MaskRenderer` with the specified library and pixel format.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for rendering.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
    ///
    /// This initializer sets up the render pipeline state for the `MaskRenderer`.
    public init(
        library: MTLLibrary,
        pixelFormat: MTLPixelFormat
    ) throws {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        self.renderPipelineState = try library.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    // MARK: - Helpers

    private func constructRectangle() -> Rectangle {
        let topLeftPosition = SIMD2<Float>(
            Float(self.normalizedRect.minX),
            Float(self.normalizedRect.maxY)
        )
        let bottomLeftPosition = SIMD2<Float>(
            Float(self.normalizedRect.minX),
            Float(self.normalizedRect.minY)
        )
        let topRightPosition = SIMD2<Float>(
            Float(self.normalizedRect.maxX),
            Float(self.normalizedRect.maxY)
        )
        let bottomRightPosition = SIMD2<Float>(
            Float(self.normalizedRect.maxX),
            Float(self.normalizedRect.minY)
        )
        return Rectangle(
            topLeft: topLeftPosition,
            bottomLeft: bottomLeftPosition,
            topRight: topRightPosition,
            bottomRight: bottomRightPosition
        )
    }

    // MARK: - Rendering

    /// Renders the mask using the specified render pass descriptor and command buffer.
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

    /// Render a rectangle with mask in a target texture.
    ///
    /// - Parameter renderEncoder: Container to put the rendering work into.
    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        guard self.normalizedRect != .zero
        else { return }

        // Push a debug group allowing us to identify render commands in the GPU Frame Capture tool.
        renderEncoder.pushDebugGroup("Draw Rectangle With Mask")
        // Set render command encoder state.
        renderEncoder.setRenderPipelineState(self.renderPipelineState)
        // Set any buffers fed into our render pipeline.
        let rectangle = self.constructRectangle()
        renderEncoder.set(
            vertexValue: rectangle,
            at: 0
        )
        renderEncoder.setFragmentTexture(
            self.maskTexture,
            index: 0
        )
        renderEncoder.set(
            fragmentValue: self.color,
            at: 0
        )
        // Draw.
        renderEncoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4
        )
        renderEncoder.popDebugGroup()
    }

    public static let vertexFunctionName = "maskVertex"
    public static let fragmentFunctionName = "maskFragment"
}
