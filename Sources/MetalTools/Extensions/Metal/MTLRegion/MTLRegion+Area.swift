import Metal

public extension MTLRegion {
    
    var minX: Int { self.origin.x }
    var minY: Int { self.origin.y }
    var minZ: Int { self.origin.z }
    var maxX: Int { self.origin.x + self.size.width }
    var maxY: Int { self.origin.y + self.size.height }
    var maxZ: Int { self.origin.z + self.size.depth }
    var area: Int { self.size.width * self.size.height }
    
}
