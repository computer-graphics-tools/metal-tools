#if os(iOS) || targetEnvironment(macCatalyst)

import Metal
import CoreGraphics
import CoreImage
import UIKit

/// A class for rendering bounding boxes using Metal.
final public class BoundingBoxesRender {

    /// A descriptor for the geometry of a bounding box.
    final public class GeometryDescriptor {
        /// The color of the bounding box.
        public let color: SIMD4<Float>

        /// The normalized line width of the bounding box.
        public let normalizedLineWidth: Float

        /// The normalized rectangle defining the bounding box.
        public let normalizedRect: SIMD4<Float>

        /// The descriptor for the label associated with the bounding box.
        public let labelDescriptor: LabelsRender.GeometryDescriptor?

        /// Initializes a new `GeometryDescriptor` with the specified parameters.
        ///
        /// - Parameters:
        ///   - color: The color of the bounding box.
        ///   - normalizedLineWidth: The normalized line width of the bounding box.
        ///   - normalizedRect: The normalized rectangle defining the bounding box.
        ///   - labelDescriptor: The descriptor for the label associated with the bounding box.
        ///
        /// This initializer sets the color, line width, rectangle, and label descriptor for the `GeometryDescriptor`.
        public init(
            color: SIMD4<Float>,
            normalizedLineWidth: Float,
            normalizedRect: SIMD4<Float>,
            labelDescriptor: LabelsRender.GeometryDescriptor?
        ) {
            self.color = color
            self.normalizedLineWidth = normalizedLineWidth
            self.normalizedRect = normalizedRect
            self.labelDescriptor = labelDescriptor
        }

        /// Convenience initializer for creating a `GeometryDescriptor` from a `CGColor` and `CGRect`.
        ///
        /// - Parameters:
        ///   - color: The color of the bounding box as a `CGColor`.
        ///   - normalizedLineWidth: The normalized line width of the bounding box.
        ///   - normalizedRect: The normalized rectangle defining the bounding box as a `CGRect`.
        ///   - labelDescriptor: The descriptor for the label associated with the bounding box.
        ///
        /// This initializer converts the `CGColor` and `CGRect` to the appropriate formats and initializes the `GeometryDescriptor`.
        public convenience init(
            color: CGColor,
            normalizedLineWidth: Float,
            normalizedRect: CGRect,
            labelDescriptor: LabelsRender.GeometryDescriptor?
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
                normalizedLineWidth: normalizedLineWidth,
                normalizedRect: normalizedRect,
                labelDescriptor: labelDescriptor
            )
        }

        /// Convenience initializer for creating a `GeometryDescriptor` with a label text.
        ///
        /// - Parameters:
        ///   - color: The color of the bounding box as a `CGColor`.
        ///   - normalizedLineWidth: The normalized line width of the bounding box.
        ///   - normalizedRect: The normalized rectangle defining the bounding box as a `CGRect`.
        ///   - labelText: The text for the label associated with the bounding box.
        ///
        /// This initializer converts the `CGColor` and `CGRect` to the appropriate formats and initializes the `GeometryDescriptor` with a label text.
        public convenience init(
            color: CGColor,
            normalizedLineWidth: Float,
            normalizedRect: CGRect,
            labelText: String?
        ) {
            var labelDescriptor: LabelsRender.GeometryDescriptor? = nil
            if let labelText = labelText {
                labelDescriptor = .init(
                    text: labelText,
                    textColor: UIColor.white.cgColor,
                    labelColor: color,
                    normalizedRect: .init(
                        origin: .init(
                            x: normalizedRect.origin.x,
                            y: normalizedRect.origin.y - 0.04
                        ),
                        size: .init(
                            width: normalizedRect.size.width / 2.3,
                            height: 0.04
                        )
                    )
                )
            }
            self.init(
                color: color,
                normalizedLineWidth: normalizedLineWidth,
                normalizedRect: normalizedRect,
                labelDescriptor: labelDescriptor
            )
        }
    }

    // MARK: - Properties
    
    /// The array of geometry descriptors for the bounding boxes.
    public var geometryDescriptors: [GeometryDescriptor] = [] {
        didSet {
            self.labelsRender.geometryDescriptors = self.geometryDescriptors.compactMap(\.labelDescriptor)
            self.updateLines()
            self.drawLables = !self.geometryDescriptors.compactMap(\.labelDescriptor).isEmpty
        }
    }
    
    /// Render target size.
    public var renderTargetSize: MTLSize = .zero {
        didSet {
            self.labelsRender.renderTargetSize = self.renderTargetSize
        }
    }

    private var drawLables: Bool = false

    private let linesRender: LinesRender
    private let labelsRender: LabelsRender

    // MARK: - Life Cicle

    /// Creates a new instance of BoundingBoxesRenderer.
    ///
    /// - Parameters:
    ///   - context: The Metal context.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Library or function creation errors.
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

    /// Creates a new instance of BoundingBoxesRenderer.
    ///
    /// - Parameters:
    ///   - library: Shader library.
    ///   - pixelFormat: Color attachment's pixel format.
    /// - Throws: Function creation error.
    public init(
        library: MTLLibrary,
        fontAtlas: MTLFontAtlas,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws {
        self.linesRender = try .init(
            library: library,
            pixelFormat: pixelFormat
        )
        self.labelsRender = try .init(
            library: library,
            fontAtlas: fontAtlas,
            pixelFormat: pixelFormat
        )
    }

    // MARK: - Helpers

    private func updateLines() {
        var linesGeometryDescriptors: [LinesRender.GeometryDescriptor] = []
        self.geometryDescriptors.forEach { descriptor in
            let textureWidth = Float(self.renderTargetSize.width)
            let textureHeight = Float(self.renderTargetSize.height)
            let horizontalWidth = descriptor.normalizedLineWidth / textureHeight * textureWidth
            let verticalWidth = descriptor.normalizedLineWidth

            let bboxMinX = descriptor.normalizedRect.x
            let bboxMinY = descriptor.normalizedRect.y + descriptor.normalizedRect.w
            let bboxMaxX = descriptor.normalizedRect.x + descriptor.normalizedRect.z
            let bboxMaxY = descriptor.normalizedRect.y

            let startPoints: [SIMD2<Float>] = [
                .init(
                    bboxMinX + verticalWidth / 2,
                    bboxMinY
                ),
                .init(
                    bboxMinX,
                    bboxMaxY + horizontalWidth / 2
                ),
                .init(
                    bboxMaxX - verticalWidth / 2,
                    bboxMaxY
                ),
                .init(
                    bboxMaxX,
                    bboxMinY - horizontalWidth / 2
                )
            ]
            let endPoints: [SIMD2<Float>] = [
                .init(
                    bboxMinX + verticalWidth / 2,
                    bboxMaxY + horizontalWidth
                ),
                .init(
                    bboxMaxX - verticalWidth,
                    bboxMaxY + horizontalWidth / 2
                ),
                .init(
                    bboxMaxX - verticalWidth / 2,
                    bboxMinY - horizontalWidth
                ),
                .init(
                    bboxMinX + verticalWidth,
                    bboxMinY - horizontalWidth / 2
                )
            ]
            let widths: [Float] = [
                verticalWidth,
                horizontalWidth,
                verticalWidth,
                horizontalWidth
            ]

            for i in 0 ..< 4 {
                linesGeometryDescriptors.append(.init(
                    startPoint: startPoints[i],
                    endPoint: endPoints[i],
                    normalizedWidth: widths[i],
                    color: descriptor.color
                ))
            }
        }
        self.linesRender
            .geometryDescriptors = linesGeometryDescriptors
    }

    // MARK: - Rendering

    /// Render bounding boxes in a target texture.
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

    /// Render bounding boxes in a target texture.
    ///
    /// - Parameter renderEncoder: Container to put the rendering work into.
    public func render(using renderEncoder: MTLRenderCommandEncoder) {
        #if DEBUG
        renderEncoder.pushDebugGroup("Draw Bounding Box Geometry")
        #endif
        self.linesRender.render(using: renderEncoder)
        if self.drawLables {
            self.labelsRender.render(using: renderEncoder)
        }
        #if DEBUG
        renderEncoder.popDebugGroup()
        #endif
    }
}

#endif
