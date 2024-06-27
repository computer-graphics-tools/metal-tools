#if os(iOS) || targetEnvironment(macCatalyst)

import MetalTools
import UIKit.UIFont

/// A class representing a font atlas for Metal rendering.
final public class MTLFontAtlas {
    /// The font associated with this atlas.
    let font: UIFont

    /// The descriptors for the glyphs in the atlas.
    let glyphDescriptors: [GlyphDescriptor]

    /// The Metal texture for the font atlas.
    let fontAtlasTexture: MTLTexture

    /// Initializes a new `MTLFontAtlas` with the specified font, glyph descriptors, and texture.
    ///
    /// - Parameters:
    ///   - font: The font associated with the atlas.
    ///   - glyphDescriptors: The descriptors for the glyphs in the atlas.
    ///   - fontAtlasTexture: The Metal texture for the font atlas.
    ///
    /// This initializer sets the font, glyph descriptors, and texture for the `MTLFontAtlas`.
    public init(
        font: UIFont,
        glyphDescriptors: [GlyphDescriptor],
        fontAtlasTexture: MTLTexture
    ) {
        self.font = font
        self.glyphDescriptors = glyphDescriptors
        self.fontAtlasTexture = fontAtlasTexture
    }

    /// Creates a codable container for this font atlas.
    ///
    /// - Returns: A `MTLFontAtlasCodableContainer` representing this font atlas.
    /// - Throws: An error if the codable container creation fails.
    ///
    /// This method creates a codable container for the `MTLFontAtlas` to support encoding and decoding.
    public func codable() throws -> MTLFontAtlasCodableContainer {
        try .init(fontAtlas: self)
    }
}

#endif
