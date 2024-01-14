import Metal

public extension MTLOrigin {
    func clamped(to size: MTLSize) -> MTLOrigin {
        .init(
            x: min(max(self.x, 0), size.width),
            y: min(max(self.y, 0), size.height),
            z: min(max(self.z, 0), size.depth)
        )
    }
}
