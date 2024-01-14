import Metal

public extension MTLRegion {
    var minX: Int { self.origin.x }
    var minY: Int { self.origin.y }
    var minZ: Int { self.origin.z }
    var maxX: Int { self.origin.x + self.size.width - 1 }
    var maxY: Int { self.origin.y + self.size.height - 1 }
    var maxZ: Int { self.origin.z + self.size.depth - 1 }
    var area: Int { self.size.width * self.size.height }
}
