#if os(iOS) || targetEnvironment(macCatalyst)

import UIKit

/// Extension for `UIFont` to provide additional functionality related to text rendering and measurement.
extension UIFont {

    /// The estimated width of a single line of text with this font.
    ///
    /// This property calculates the estimated width of a single line of text using the "!" character.
    var estimatedLineWidth: CGFloat {
        let string: NSString = "!"
        let stringSize = string.size(withAttributes: [NSAttributedString.Key.font : self])
        return .init(ceilf(.init(stringSize.width)))
    }

    /// The estimated size of a glyph with this font.
    ///
    /// This property calculates the estimated size of a glyph using a sample string of characters.
    var estimatedGlyphSize: CGSize {
        let string: NSString = "{ǺOJMQYZa@jmqyw"
        let stringSize = string.size(withAttributes: [NSAttributedString.Key.font : self])
        let averageGlyphWidth = CGFloat(ceilf(.init(stringSize.width) / .init(string.length)))
        let maxGlyphHeight = CGFloat(ceilf(.init(stringSize.height)))
        return .init(
            width: averageGlyphWidth,
            height: maxGlyphHeight
        )
    }

    /// The Core Text font representation of this font.
    ///
    /// This property provides a `CTFont` representation of the `UIFont`.
    var ctFont: CTFont {
        CTFontCreateWithName(
            self.fontName as CFString,
            self.pointSize,
            nil
        )
    }

    /// Determines if a string with a specified font fits within a given rectangle.
    ///
    /// - Parameters:
    ///   - font: The font to use for the string.
    ///   - rect: The rectangle to fit the string into.
    ///   - characterCount: The number of characters to fit within the rectangle.
    /// - Returns: `true` if the string fits within the rectangle, otherwise `false`.
    ///
    /// This method checks if the given string with the specified font fits within the provided rectangle.
    private static func stringWithFontFitsInRect(
        font: UIFont,
        rect: CGRect,
        characterCount: Int
    ) -> Bool {
        let area = rect.size.width * rect.size.height
        let glyphMargin = font.estimatedLineWidth
        let averageGlyphSize = font.estimatedGlyphSize
        let estimatedGlyphTotalArea = (averageGlyphSize.width + glyphMargin)
            * (averageGlyphSize.height + glyphMargin)
            * .init(characterCount)
        return estimatedGlyphTotalArea < area
    }
    
    /// Calculates the font size to fit within an atlas rectangle and returns the appropriate `UIFont` object.
    ///
    /// - Parameters:
    ///   - fontName: The name of the font.
    ///   - atlasRect: The rectangle defining the bounds of the atlas.
    ///   - trialFontSize: The initial font size to try for fitting. Defaults to 32.
    /// - Returns: The `UIFont` object with the calculated size that fits within the atlas rectangle, or `nil` if the font cannot be created.
    ///
    /// This method creates a temporary font to estimate the glyph count, then calculates the font size that fits within the specified atlas rectangle, and returns the corresponding `UIFont` object.
    public static func atlasFont(
        name fontName: String,
        atlasRect: CGRect,
        trialFontSize: CGFloat = 32
    ) -> UIFont? {
        guard let temporaryFont = UIFont(
            name: fontName,
            size: 8
        )
        else { return nil }
        let glyphCount = CTFontGetGlyphCount(temporaryFont.ctFont)
        let fittedPointSize = Self.calculateFontSizeToFit(
            rect: atlasRect,
            fontName: fontName,
            characterCount: glyphCount,
            trialFontSize: trialFontSize
        )

        return UIFont(
            name: fontName,
            size: fittedPointSize
        )
    }

    /// Calculates the font size that fits within a specified rectangle.
    ///
    /// - Parameters:
    ///   - rect: The rectangle to fit the font size into.
    ///   - fontName: The name of the font.
    ///   - characterCount: The number of characters to fit within the rectangle.
    /// - Returns: The calculated font size.
    ///
    /// This method calculates the font size that will fit within the specified rectangle for a given character count.
    static func calculateFontSizeToFit(
        rect: CGRect,
        fontName: String,
        characterCount: Int,
        trialFontSize: CGFloat = 32
    ) -> CGFloat {
        var fittedSize = trialFontSize
        while let trialFont = UIFont(
            name: fontName,
            size: fittedSize
        ),
            UIFont.stringWithFontFitsInRect(
                font: trialFont,
                rect: rect,
                characterCount: characterCount
            )
        {
            fittedSize += 1
        }

        while let trialFont = UIFont(
            name: fontName,
            size: fittedSize
        ),
            !UIFont.stringWithFontFitsInRect(
                font: trialFont,
                rect: rect,
                characterCount: characterCount
            )
        {
            fittedSize -= 1
        }
        return fittedSize
    }
}

#endif
