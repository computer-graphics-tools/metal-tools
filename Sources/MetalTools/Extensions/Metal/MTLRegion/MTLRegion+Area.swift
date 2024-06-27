import Metal

public extension MTLRegion {
    /// The minimum x-coordinate of the region.
    var minX: Int { self.origin.x }

    /// The minimum y-coordinate of the region.
    var minY: Int { self.origin.y }

    /// The minimum z-coordinate of the region.
    var minZ: Int { self.origin.z }

    /// The maximum x-coordinate of the region (inclusive).
    var maxX: Int { self.origin.x + self.size.width - 1 }

    /// The maximum y-coordinate of the region (inclusive).
    var maxY: Int { self.origin.y + self.size.height - 1 }

    /// The maximum z-coordinate of the region (inclusive).
    var maxZ: Int { self.origin.z + self.size.depth - 1 }

    /// The area of the region in the XY plane.
    var area: Int { self.size.width * self.size.height }
}
