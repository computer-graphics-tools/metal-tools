import MetalTools
import Metal

/// A class for rendering simple geometries using Metal.
final public class SimpleGeometryRenderer {
    // MARK: - Properties

    /// The render pipeline state for rendering simple geometries.
    public let pipelineState: MTLRenderPipelineState

    // MARK: - Init

    /// Creates a new instance of `SimpleGeometryRenderer`.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - pixelFormat: Color attachment's pixel format.
    ///   - blending: Blending mode for the renderer. Defaults to `.alpha`.
    ///   - label: A label for the renderer. Defaults to "Simple Geometry Renderer".
    /// - Throws: An error if initialization fails.
    ///
    /// This convenience initializer sets up the renderer with the specified context, pixel format, blending mode, and label.
    public convenience init(
        context: MTLContext,
        pixelFormat: MTLPixelFormat,
        blending: BlendingMode = .alpha,
        label: String = "Simple Geometry Renderer"
    ) throws {
        try self.init(
            library: context.library(for: Self.self),
            pixelFormat: pixelFormat,
            blending: blending,
            label: label
        )
    }

    /// Creates a new instance of `SimpleGeometryRenderer` with the specified library, pixel format, blending mode, and label.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for rendering.
    ///   - pixelFormat: Color attachment's pixel format.
    ///   - blending: Blending mode for the renderer. Defaults to `.alpha`.
    ///   - label: A label for the renderer. Defaults to "Simple Geometry Renderer".
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the render pipeline state for the `SimpleGeometryRenderer`.
    public init(
        library: MTLLibrary,
        pixelFormat: MTLPixelFormat,
        blending: BlendingMode = .alpha,
        label: String = "Simple Geometry Renderer"
    ) throws {
        guard let vertexFunction = library.makeFunction(name: Self.vertexFunctionName),
              let fragmentFunction = library.makeFunction(name: Self.fragmentFunctionName)
        else { throw MetalError.MTLLibraryError.functionCreationFailed }

        let renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.label = label
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        renderPipelineStateDescriptor.colorAttachments[0].setup(blending: blending)
        renderPipelineStateDescriptor.depthAttachmentPixelFormat = .invalid
        renderPipelineStateDescriptor.stencilAttachmentPixelFormat = .invalid

        try self.pipelineState = library.device.makeRenderPipelineState(descriptor: renderPipelineStateDescriptor)
    }

    // MARK: - Render

    /// Renders the specified geometry using the given parameters.
    ///
    /// - Parameters:
    ///   - geometry: The buffer containing the geometry data.
    ///   - type: The type of primitives to render. Defaults to `.triangle`.
    ///   - fillMode: The fill mode for rendering the primitives. Defaults to `.fill`.
    ///   - indexBuffer: The index buffer to use for rendering.
    ///   - matrix: The transformation matrix to apply to the geometry. Defaults to an identity matrix.
    ///   - color: The color to use for rendering the geometry.
    ///   - encoder: The command encoder to use for rendering.
    /// - Throws: An error if rendering fails.
    ///
    /// This method sets up the render pipeline and encodes the rendering commands for the specified geometry.
    public func render(
        geometry: MTLBuffer,
        type: MTLPrimitiveType = .triangle,
        fillMode: MTLTriangleFillMode = .fill,
        indexBuffer: MTLIndexBuffer,
        matrix: float4x4 = float4x4(diagonal: .init(repeating: 1)),
        color: SIMD4<Float> = .init(1, 0, 0, 1),
        using encoder: MTLRenderCommandEncoder
    ) {
        encoder.setVertexBuffer(
            geometry,
            offset: 0,
            index: 0
        )
        encoder.set(
            vertexValue: matrix,
            at: 1
        )
        encoder.set(
            fragmentValue: color,
            at: 0
        )
        encoder.setTriangleFillMode(fillMode)
        encoder.setRenderPipelineState(self.pipelineState)
        encoder.drawIndexedPrimitives(
            type: type,
            indexBuffer: indexBuffer
        )
    }

    public static let vertexFunctionName = "simpleVertex"
    public static let fragmentFunctionName = "simpleFragment"
}
