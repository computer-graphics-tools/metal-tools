import Metal

public extension MTLSize {
    init(repeating value: Int) {
        self.init(
            width: value,
            height: value,
            depth: value
        )
    }

    static let one = MTLSize(repeating: 1)
    static let zero = MTLSize(repeating: 0)
}
