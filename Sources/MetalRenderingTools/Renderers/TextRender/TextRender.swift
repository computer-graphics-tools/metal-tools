#if os(iOS) || targetEnvironment(macCatalyst)

import Metal
import CoreGraphics
import CoreImage

/// A class for rendering text using Metal.
final public class TextRender {
    
    /// A descriptor for the geometry of text.
    public class GeometryDescriptor: Equatable, Hashable {
        /// The text to be rendered.
        let text: String
        
        /// The normalized rectangle defining the bounds of the text.
        let normalizedRect: SIMD4<Float>
        
        /// The color of the text.
        let color: SIMD4<Float>
        
        /// Convenience initializer for creating a `GeometryDescriptor` from `String`, `CGRect`, and `CGColor`.
        ///
        /// - Parameters:
        ///   - text: The text to be rendered.
        ///   - normalizedRect: The normalized rectangle defining the bounds of the text as a `CGRect`.
        ///   - color: The color of the text as a `CGColor`.
        ///
        /// This initializer converts the `CGRect` and `CGColor` to the appropriate formats and initializes the `GeometryDescriptor`.
        public convenience init(
            text: String,
            normalizedRect: CGRect,
            color: CGColor
        ) {
            let normalizedRect = SIMD4<Float>(
                .init(normalizedRect.origin.x),
                .init(normalizedRect.origin.y),
                .init(normalizedRect.size.width),
                .init(normalizedRect.size.height)
            )
            let ciColor = CIColor(cgColor: color)
            let textColor = SIMD4<Float>(
                .init(ciColor.red),
                .init(ciColor.green),
                .init(ciColor.blue),
                .init(ciColor.alpha)
            )
            self.init(
                text: text,
                normalizedRect: normalizedRect,
                color: textColor
            )
        }
        
        /// Initializes a new `GeometryDescriptor` with the specified parameters.
        ///
        /// - Parameters:
        ///   - text: The text to be rendered.
        ///   - normalizedRect: The normalized rectangle defining the bounds of the text.
        ///   - color: The color of the text.
        ///
        /// This initializer sets the text, normalized rectangle, and color for the `GeometryDescriptor`.
        public init(
            text: String,
            normalizedRect: SIMD4<Float>,
            color: SIMD4<Float>
        ) {
            self.text = text
            self.normalizedRect = normalizedRect
            self.color = color
        }
        
        /// Equatable protocol implementation.
        ///
        /// - Parameters:
        ///   - lhs: The left-hand side `GeometryDescriptor` to compare.
        ///   - rhs: The right-hand side `GeometryDescriptor` to compare.
        /// - Returns: `true` if the descriptors are equal, otherwise `false`.
        public static func == (lhs: GeometryDescriptor, rhs: GeometryDescriptor) -> Bool {
            return lhs.text == rhs.text &&
            lhs.normalizedRect == rhs.normalizedRect &&
            lhs.color == rhs.color
        }
        
        /// Hashable protocol implementation.
        ///
        /// - Parameter hasher: The hasher to use when combining the components of this instance.
        ///
        /// This method combines the text, normalized rectangle, and color into the hasher.
        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(normalizedRect)
            hasher.combine(color)
        }
    }
    
    // MARK: - Propertires
    
    /// The render pipeline state for rendering text.
    public let pipelineState: MTLRenderPipelineState
    
    /// The sampler state for sampling textures.
    public let sampler: MTLSamplerState
    
    /// The font atlas used for rendering text.
    private let fontAtlas: MTLFontAtlas
    
    /// Render taregt texture size.
    public var renderTargetSize: MTLSize = .zero {
        didSet {
            if self.renderTargetSize != oldValue {
                self.projectionMatrix = self.matrixOrthographicProjection(
                    left: 0,
                    right: .init(self.renderTargetSize.width),
                    top: 0,
                    bottom: .init(self.renderTargetSize.height)
                )
            }
        }
    }
    
    /// The array of geometry descriptors for the text.
    public var geometryDescriptors: [GeometryDescriptor] = [] {
        didSet { self.updateGeometry() }
    }
    
    private var textMeshes: [TextMesh] = []
    private var projectionMatrix = matrix_identity_float4x4
    private var needsUpdateTextMesh: Bool = true
    
    // MARK: - Life Cycle
    
    /// Creates a new instance of `TextRender`.
    ///
    /// - Parameters:
    ///   - context: The Metal context to use for rendering.
    ///   - fontAtlas: The font atlas to use for rendering text.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
    ///
    /// This initializer sets up the render pipeline state, sampler state, and prepares the renderer for rendering text.
    public convenience init(
        context: MTLContext,
        fontAtlas: MTLFontAtlas,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        try self.init(
            library: context.library(for: .module),
            fontAtlas: fontAtlas,
            pixelFormat: pixelFormat
        )
    }
    
    /// Creates a new instance of `TextRender`.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for rendering.
    ///   - fontAtlas: The font atlas to use for rendering text.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
    ///
    /// This initializer sets up the render pipeline state, sampler state, and prepares the renderer for rendering text.
    public init(
        library: MTLLibrary,
        fontAtlas: MTLFontAtlas,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        self.fontAtlas = fontAtlas
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.sAddressMode = .clampToZero
        samplerDescriptor.tAddressMode = .clampToZero
        guard let sampler = library.device.makeSamplerState(descriptor: samplerDescriptor)
        else { throw MetalError.MTLDeviceError.samplerStateCreationFailed }
        self.sampler = sampler
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
        pipelineDescriptor.colorAttachments[0].setup(blending: .alpha)
        
        pipelineDescriptor.depthAttachmentPixelFormat = .invalid
        pipelineDescriptor.vertexFunction = library.makeFunction(name: Self.vertexFunctionName)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: Self.fragmentFunctionName)
        pipelineDescriptor.vertexDescriptor = Self.vertexDescriptor()
        
        self.pipelineState = try library.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    private func setNeedsUpdateTextMesh() {
        self.needsUpdateTextMesh = true
    }
    
    private func matrixOrthographicProjection(
        left: Float,
        right: Float,
        top: Float,
        bottom: Float,
        near: Float = 0,
        far: Float = 1
    ) -> matrix_float4x4 {
        let sx: Float = 2 / (right - left);
        let sy: Float = 2 / (top - bottom);
        let sz: Float = 1 / (far - near);
        let tx: Float = (right + left) / (left - right);
        let ty: Float = (top + bottom) / (bottom - top);
        let tz: Float = near / (far - near);
        
        let P = vector_float4(sx, 0, 0, 0)
        let Q = vector_float4(0, sy, 0, 0)
        let R = vector_float4(0, 0, sz, 0)
        let S = vector_float4(tx, ty, tz, 1)
        
        return .init(P, Q, R, S)
    }
    
    private func updateGeometry() {
        self.textMeshes.removeAll()
        self.geometryDescriptors.forEach { descriptor in
            let normalizedRect = descriptor.normalizedRect
            let targetWidth = Float(self.renderTargetSize.width)
            let targetHeight = Float(self.renderTargetSize.height)
            let rect = SIMD4<Float>(
                normalizedRect.x * targetWidth,
                normalizedRect.y * targetHeight,
                normalizedRect.z * targetWidth,
                normalizedRect.w * targetHeight
            )
            try? self.textMeshes.append(.init(
                string: descriptor.text,
                rect: rect,
                fontAtlas: self.fontAtlas,
                device: self.pipelineState.device
            ))
        }
    }
    
    // MARK: - Draw
    
    /// Render a rectangle in a target texture.
    ///
    /// - Parameters:
    ///   - renderPassDescriptor: Render pass descriptor to be used.
    ///   - commandBuffer: Command buffer to put the rendering work items into.
    public func render(
        renderPassDescriptor: MTLRenderPassDescriptor,
        commandBuffer: MTLCommandBuffer
    ) throws {
        self.renderTargetSize = renderPassDescriptor.colorAttachments[0].texture?.size ?? .zero
        commandBuffer.render(
            descriptor: renderPassDescriptor,
            self.render(using:)
        )
    }
    
    /// Render a rectangle in a target texture.
    ///
    /// - Parameter renderEncoder: Container to put the rendering work into.
    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        guard !self.textMeshes.isEmpty
        else { return }
        
        renderEncoder.pushDebugGroup("Draw Text Geometry")
        defer { renderEncoder.popDebugGroup() }
        
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setCullMode(.none)
        renderEncoder.setRenderPipelineState(self.pipelineState)
        self.textMeshes.enumerated().forEach { index, textMesh in
            renderEncoder.setVertexBuffer(
                textMesh.vertexBuffer,
                offset: 0,
                index: 0
            )
            renderEncoder.setVertexBytes(
                &self.projectionMatrix,
                length: MemoryLayout<matrix_float4x4>.stride,
                index: 1
            )
            
            renderEncoder.setFragmentTexture(
                self.fontAtlas
                    .fontAtlasTexture,
                index: 0
            )
            
            var color = self.geometryDescriptors[index].color
            renderEncoder.setFragmentBytes(
                &color,
                length: MemoryLayout<SIMD4<Float>>.stride,
                index: 0
            )
            renderEncoder.setFragmentSamplerState(
                self.sampler,
                index: 0
            )
            
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: textMesh.indexBuffer.length / MemoryLayout<UInt16>.stride,
                indexType: .uint16,
                indexBuffer: textMesh.indexBuffer,
                indexBufferOffset: 0
            )
        }
    }
    
    private static func vertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stepFunction = .perVertex
        vertexDescriptor.layouts[0].stride = MemoryLayout<TextMeshVertex>.stride
        return vertexDescriptor
    }
    
    public static let vertexFunctionName = "textVertex"
    public static let fragmentFunctionName = "textFragment"
}

#endif
