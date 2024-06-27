#if os(iOS) || targetEnvironment(macCatalyst)

import Metal
import UIKit.UIFont

/// A descriptor for a font atlas used in Metal rendering.
public final class MTLFontAtlasDescriptor: Hashable {
    /// The name of the font.
    let fontName: String

    /// The size of the texture for the font atlas.
    let textureSize: Int

    /// Initializes a new `MTLFontAtlasDescriptor` with the specified font name and texture size.
    ///
    /// - Parameters:
    ///   - fontName: The name of the font.
    ///   - textureSize: The size of the texture for the font atlas.
    ///
    /// This initializer sets the font name and texture size for the `MTLFontAtlasDescriptor`.
    public init(
        fontName: String,
        textureSize: Int
    ) {
        self.fontName = fontName
        self.textureSize = textureSize
    }

    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    ///
    /// This method combines the `fontName` and `textureSize` properties into the hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.fontName)
        hasher.combine(self.textureSize)
    }

    /// Returns a Boolean value indicating whether two font atlas descriptors are equal.
    ///
    /// - Parameters:
    ///   - lhs: A font atlas descriptor to compare.
    ///   - rhs: Another font atlas descriptor to compare.
    /// - Returns: `true` if the two descriptors are equal, otherwise `false`.
    ///
    /// This method compares the `fontName` and `textureSize` properties of the two descriptors.
    public static func == (
        lhs: MTLFontAtlasDescriptor,
        rhs: MTLFontAtlasDescriptor
    ) -> Bool {
        lhs.fontName == rhs.fontName && lhs.textureSize == rhs.textureSize
    }
}

#endif
