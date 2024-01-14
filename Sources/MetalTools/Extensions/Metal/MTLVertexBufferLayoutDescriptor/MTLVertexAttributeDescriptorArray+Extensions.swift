import Metal

extension MTLVertexBufferLayoutDescriptor {
    convenience init(stride: Int, stepFunction: MTLVertexStepFunction = .perVertex, stepRate: Int = 1) {
        self.init()
        self.stride = stride
        self.stepFunction = stepFunction
        self.stepRate = stepRate
    }
}
