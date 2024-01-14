import Metal

extension MTLOrigin: Equatable {
    public static func ==(lhs: MTLOrigin, rhs: MTLOrigin) -> Bool {
        lhs.x == rhs.x
            && lhs.y == rhs.y
            && lhs.z == rhs.z
    }
}
