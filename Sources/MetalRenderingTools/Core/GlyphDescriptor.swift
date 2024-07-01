#if os(iOS) || targetEnvironment(macCatalyst)

import CoreGraphics
import CoreText
import Foundation

/// A descriptor for a glyph, containing its index and coordinates.
public final class GlyphDescriptor {
    /// The index of the glyph.
    public var glyphIndex: CGGlyph

    /// The top-left coordinate of the glyph.
    public var topLeftCoordinate: SIMD2<Float>

    /// The bottom-right coordinate of the glyph.
    public var bottomRightCoordinate: SIMD2<Float>

    /// Initializes a new GlyphDescriptor with the specified glyph index and coordinates.
    ///
    /// - Parameters:
    ///   - glyphIndex: The index of the glyph.
    ///   - topLeftCoordinate: The top-left coordinate of the glyph.
    ///   - bottomRightCoordinate: The bottom-right coordinate of the glyph.
    ///
    /// This initializer sets the glyph index and coordinates for the GlyphDescriptor.
    public init(
        glyphIndex: UInt,
        topLeftCoordinate: SIMD2<Float>,
        bottomRightCoordinate: SIMD2<Float>
    ) {
        self.glyphIndex = .init(glyphIndex)
        self.topLeftCoordinate = topLeftCoordinate
        self.bottomRightCoordinate = bottomRightCoordinate
    }
}

/// Conforms GlyphDescriptor to the Codable protocol to support encoding and decoding.
extension GlyphDescriptor: Codable { }

#endif
