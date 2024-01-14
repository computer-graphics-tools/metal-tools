#if os(iOS) || targetEnvironment(macCatalyst)

import MetalTools
import UIKit.UIFont

final public class MTLFontAtlas {
    let font: UIFont
    let glyphDescriptors: [GlyphDescriptor]
    let fontAtlasTexture: MTLTexture

    public init(
        font: UIFont,
        glyphDescriptors: [GlyphDescriptor],
        fontAtlasTexture: MTLTexture
    ) {
        self.font = font
        self.glyphDescriptors = glyphDescriptors
        self.fontAtlasTexture = fontAtlasTexture
    }

    public func codable() throws -> MTLFontAtlasCodableContainer {
        try .init(fontAtlas: self)
    }
}

#endif
