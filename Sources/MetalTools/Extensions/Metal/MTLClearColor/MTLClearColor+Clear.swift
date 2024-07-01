import Metal

public extension MTLClearColor {
    /// A pre-defined clear color representing fully transparent black.
    ///
    /// This color has all components (red, green, blue, and alpha) set to 0,
    /// resulting in a fully transparent pixel when used as a clear color.
    static let clear = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
}
