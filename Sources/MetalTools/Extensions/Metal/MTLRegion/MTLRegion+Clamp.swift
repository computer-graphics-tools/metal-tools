import Metal

public extension MTLRegion {
    
    func clamped(to region: MTLRegion) -> MTLRegion? {
        let ox = max(self.origin.x, region.origin.x)
        let oy = max(self.origin.y, region.origin.y)
        let oz = max(self.origin.z, region.origin.z)
        
        let maxX = min(self.maxX, region.maxX)
        let maxY = min(self.maxY, region.maxY)
        let maxZ = min(self.maxZ, region.maxZ)
        
        guard ox < maxX && oy < maxY && oz < maxZ
        else { return nil }
        
        return .init(origin: .init(x: ox,
                                   y: oy,
                                   z: oz),
                     size: .init(width:  maxX - ox,
                                 height: maxY - oy,
                                 depth:  maxZ - oz))
        
    }

}
