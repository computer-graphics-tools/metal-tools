import Metal

public extension MTLSize {
    
    func clamped(to size: MTLSize) -> MTLSize {
        return .init(width:  min(max(self.width, 0), size.width),
                     height: min(max(self.height, 0), size.height),
                     depth:  min(max(self.depth, 0), size.depth))
    }
    
}
