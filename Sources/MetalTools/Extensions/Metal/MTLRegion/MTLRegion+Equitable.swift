import Metal

extension MTLRegion: Equatable {

    public static func ==(lhs: MTLRegion, rhs: MTLRegion) -> Bool {
        return lhs.origin == rhs.origin
            && lhs.size == rhs.size
    }
    
}
