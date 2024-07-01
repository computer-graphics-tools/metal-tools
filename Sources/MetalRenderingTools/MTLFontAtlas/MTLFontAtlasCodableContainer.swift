#if os(iOS) || targetEnvironment(macCatalyst)

import MetalTools
import UIKit.UIFont

/// A codable container for `MTLFontAtlas` to support encoding and decoding.
final public class MTLFontAtlasCodableContainer: Codable {
    /// The name of the font.
    private let fontName: String

    /// The size of the font.
    private let fontSize: CGFloat

    /// The descriptors for the glyphs in the atlas.
    private let glyphDescriptors: [GlyphDescriptor]

    /// A codable container for the Metal texture of the font atlas.
    private let fontAtlasTextureCodableBox: MTLTextureCodableContainer

    /// Initializes a new `MTLFontAtlasCodableContainer` with the specified font atlas.
    ///
    /// - Parameter fontAtlas: The font atlas to create a codable container for.
    /// - Throws: An error if the texture codable container creation fails.
    ///
    /// This initializer sets the properties of the `MTLFontAtlasCodableContainer` based on the provided font atlas.
    public init(fontAtlas: MTLFontAtlas) throws {
        self.fontName = fontAtlas.font.fontName
        self.fontSize = fontAtlas.font.pointSize
        self.glyphDescriptors = fontAtlas.glyphDescriptors
        self.fontAtlasTextureCodableBox = try fontAtlas.fontAtlasTexture.codable()
    }

    /// Creates a `MTLFontAtlas` from this codable container.
    ///
    /// - Parameter device: The Metal device to use for creating the texture.
    /// - Returns: The created `MTLFontAtlas`.
    /// - Throws: An error if the font atlas creation fails.
    ///
    /// This method creates a `MTLFontAtlas` using the properties stored in this codable container.
    public func fontAtlas(device: MTLDevice) throws -> MTLFontAtlas {
        try .init(
            font: .init(
                name: self.fontName,
                size: self.fontSize
            )!,
            glyphDescriptors: self.glyphDescriptors,
            fontAtlasTexture: self.fontAtlasTextureCodableBox.texture(device: device)
        )
    }
}

#endif
