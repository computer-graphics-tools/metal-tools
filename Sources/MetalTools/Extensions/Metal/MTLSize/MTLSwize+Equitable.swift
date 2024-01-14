import Metal

extension MTLSize: Equatable {
    public static func ==(lhs: MTLSize, rhs: MTLSize) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height && lhs.depth == rhs.depth
    }
}
