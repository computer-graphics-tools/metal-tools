#if os(iOS) || targetEnvironment(macCatalyst)

import MetalTools
import CoreGraphics

/// A class for rendering labels using Metal.
final public class LabelsRender {

    /// A descriptor for the geometry of a label.
    final public class GeometryDescriptor {
        /// The text descriptor for the label.
        public let textDescriptor: TextRender.GeometryDescriptor

        /// The rectangle descriptor for the label.
        public let rectDescriptor: RectangleRender.GeometryDescriptor

        /// Initializes a new `GeometryDescriptor` with the specified text and rectangle descriptors.
        ///
        /// - Parameters:
        ///   - textDescriptor: The text descriptor for the label.
        ///   - rectDescriptor: The rectangle descriptor for the label.
        ///
        /// This initializer sets the text and rectangle descriptors for the `GeometryDescriptor`.
        public init(
            textDescriptor: TextRender.GeometryDescriptor,
            rectDescriptor: RectangleRender.GeometryDescriptor
        ) {
            self.textDescriptor = textDescriptor
            self.rectDescriptor = rectDescriptor
        }

        /// Convenience initializer for creating a `GeometryDescriptor` from label text and colors.
        ///
        /// - Parameters:
        ///   - text: The text of the label.
        ///   - textColor: The color of the text.
        ///   - labelColor: The color of the label background.
        ///   - normalizedRect: The normalized rectangle defining the label's bounds.
        ///   - textOffsetFactor: The offset factor for the text within the label. Defaults to 0.1.
        ///
        /// This initializer creates text and rectangle descriptors based on the provided label text and colors.
        public convenience init(
            text: String,
            textColor: CGColor,
            labelColor: CGColor,
            normalizedRect: CGRect,
            textOffsetFactor: CGFloat = 0.1
        ) {
            let textOriginX = normalizedRect.origin.x + normalizedRect.size.width * textOffsetFactor
            let textOriginY = normalizedRect.origin.y + normalizedRect.size.height * textOffsetFactor
            let textWidth = normalizedRect.size.width * (1 - textOffsetFactor * 2)
            let textHeight = normalizedRect.size.height * (1 - textOffsetFactor * 2)
            let textNormalizedRect = CGRect(
                x: textOriginX,
                y: textOriginY,
                width: textWidth,
                height: textHeight
            )
            self.init(
                textDescriptor: .init(
                    text: text,
                    normalizedRect: textNormalizedRect,
                    color: textColor
                ),
                rectDescriptor: .init(
                    color: labelColor,
                    normalizedRect: normalizedRect
                )
            )
        }
    }

    // MARK: - Properties

    /// The array of geometry descriptors for the labels.
    public var geometryDescriptors: [GeometryDescriptor] = [] {
        didSet { self.updateGeometry() }
    }

    /// The size of the render target.
    public var renderTargetSize: MTLSize = .zero {
        didSet {
            self.textRender.renderTargetSize = self.renderTargetSize
        }
    }

    /// The text renderer used for rendering text.
    private let textRender: TextRender

    /// The rectangle renderer used for rendering rectangles.
    private let rectangleRender: RectangleRender

    // MARK: - Life Cycle

    /// Convenience initializer for creating a `LabelsRender` with a context and font atlas.
    ///
    /// - Parameters:
    ///   - context: The Metal context to use for rendering.
    ///   - fontAtlas: The font atlas to use for rendering text.
    ///   - pixelFormat: The pixel format for the render target. Defaults to `.bgra8Unorm`.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the label renderer with the specified context and font atlas.
    public convenience init(
        context: MTLContext,
        fontAtlas: MTLFontAtlas,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        try self.init(
            library: context.library(for: Self.self),
            fontAtlas: fontAtlas,
            pixelFormat: pixelFormat
        )
    }

    /// Initializes a new `LabelsRender` with the specified library, font atlas, and pixel format.
    ///
    /// - Parameters:
    ///   - library: The Metal library to use for rendering.
    ///   - fontAtlas: The font atlas to use for rendering text.
    ///   - pixelFormat: The pixel format for the render target. Defaults to `.bgra8Unorm`.
    /// - Throws: An error if initialization fails.
    ///
    /// This initializer sets up the text and rectangle renderers for the `LabelsRender`.
    public init(
        library: MTLLibrary,
        fontAtlas: MTLFontAtlas,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        self.textRender = try .init(
            library: library,
            fontAtlas: fontAtlas,
            pixelFormat: pixelFormat
        )
        self.rectangleRender = try .init(library: library)
    }

    /// Updates the geometry for the labels based on the current descriptors.
    ///
    /// This method updates the geometry for the labels by using the text and rectangle descriptors.
    private func updateGeometry() {
        self.rectangleRender.geometryDescriptors = self.geometryDescriptors.map(\.rectDescriptor)
        self.textRender.geometryDescriptors = self.geometryDescriptors.map(\.textDescriptor)
    }


    // MARK: - Rendering

    /// Renders the labels using the specified render pass descriptor and command buffer.
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
        self.renderTargetSize = renderPassDescriptor.colorAttachments[0].texture?.size ?? .zero
        commandBuffer.render(
            descriptor: renderPassDescriptor,
            self.render(using:)
        )
    }

    /// Renders the labels using the specified render command encoder.
    ///
    /// - Parameter renderEncoder: The render command encoder to use for rendering.
    ///
    /// This method encodes the rendering commands for drawing the labels.
    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        #if DEBUG
        renderEncoder.pushDebugGroup("Draw Labels Geometry")
        #endif
        self.rectangleRender.render(using: renderEncoder)
        self.textRender.render(using: renderEncoder)
        #if DEBUG
        renderEncoder.popDebugGroup()
        #endif
    }
}

#endif
