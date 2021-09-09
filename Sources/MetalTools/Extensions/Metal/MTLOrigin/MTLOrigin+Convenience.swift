import Metal

public extension MTLOrigin {
    
    init(repeating value: Int) {
        self.init(x: value,
                  y: value,
                  z: value)
    }

    static let zero = MTLOrigin(repeating: 0)

}
