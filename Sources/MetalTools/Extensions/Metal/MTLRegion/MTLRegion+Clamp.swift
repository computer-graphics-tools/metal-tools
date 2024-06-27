import Metal

public extension MTLRegion {
    /// Clamps the current region to fit within another region.
    ///
    /// This method calculates the intersection of the current region with the provided region.
    /// If there's no overlap between the regions, it returns nil.
    ///
    /// - Parameter region: The region to clamp this region to.
    /// - Returns: A new `MTLRegion` representing the intersection of the two regions, or nil if there's no overlap.
    func clamped(to region: MTLRegion) -> MTLRegion? {
        let ox = max(self.origin.x, region.origin.x)
        let oy = max(self.origin.y, region.origin.y)
        let oz = max(self.origin.z, region.origin.z)

        let maxX = min(self.maxX, region.maxX)
        let maxY = min(self.maxY, region.maxY)
        let maxZ = min(self.maxZ, region.maxZ)

        guard ox < maxX, oy < maxY, oz < maxZ
        else { return nil }

        return .init(
            origin: .init(
                x: ox,
                y: oy,
                z: oz
            ),
            size: .init(
                width:  maxX - ox + 1,
                height: maxY - oy + 1,
                depth:  maxZ - oz + 1
            )
        )
    }
}
