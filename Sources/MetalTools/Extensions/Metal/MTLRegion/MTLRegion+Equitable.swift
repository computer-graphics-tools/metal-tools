import Metal

extension MTLRegion: Equatable {
    public static func ==(lhs: MTLRegion, rhs: MTLRegion) -> Bool {
        lhs.origin == rhs.origin
            && lhs.size == rhs.size
    }
}
