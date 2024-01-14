#if os(iOS) || targetEnvironment(macCatalyst)

import MetalTools
import UIKit.UIFont

final public class MTLFontAtlasCodableContainer: Codable {
    private let fontName: String
    private let fontSize: CGFloat
    private let glyphDescriptors: [GlyphDescriptor]
    private let fontAtlasTextureCodableBox: MTLTextureCodableContainer

    public init(fontAtlas: MTLFontAtlas) throws {
        self.fontName = fontAtlas.font.fontName
        self.fontSize = fontAtlas.font.pointSize
        self.glyphDescriptors = fontAtlas.glyphDescriptors
        self.fontAtlasTextureCodableBox = try fontAtlas.fontAtlasTexture.codable()
    }

    public func fontAtlas(device: MTLDevice) throws -> MTLFontAtlas {
        return try .init(font: .init(name: self.fontName,
                                     size: self.fontSize)!,
                         glyphDescriptors: self.glyphDescriptors,
                         fontAtlasTexture: self.fontAtlasTextureCodableBox
                                               .texture(device: device))
    }
}

#endif
