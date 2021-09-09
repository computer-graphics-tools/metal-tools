import Metal

public extension MTLCommandBuffer {

    @available(iOS 12.0, macOS 10.14, *)
    func compute(dispatch: MTLDispatchType,
                 _ commands: (MTLComputeCommandEncoder) -> Void) {
        guard let encoder = self.makeComputeCommandEncoder(dispatchType: dispatch)
        else { return }

        commands(encoder)
        
        encoder.endEncoding()
    }

    func compute(_ commands: (MTLComputeCommandEncoder) -> Void) {
        guard let encoder = self.makeComputeCommandEncoder()
        else { return }

        commands(encoder)
        
        encoder.endEncoding()
    }

    func blit(_ commands: (MTLBlitCommandEncoder) -> Void) {
        guard let encoder = self.makeBlitCommandEncoder()
        else { return }

        commands(encoder)
        
        encoder.endEncoding()
    }

    func render(descriptor: MTLRenderPassDescriptor,
                _ commands: (MTLRenderCommandEncoder) -> Void) {
        guard let encoder = self.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }

        commands(encoder)
        
        encoder.endEncoding()
    }
}
