#if os(iOS) || targetEnvironment(macCatalyst)

import CoreGraphics
import CoreText
import Foundation

final public class GlyphDescriptor {
    var glyphIndex: CGGlyph
    var topLeftCoordinate: SIMD2<Float>
    var bottomRightCoordinate: SIMD2<Float>

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

extension GlyphDescriptor: Codable { }

#endif
