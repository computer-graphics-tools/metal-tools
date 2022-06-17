import Metal

public extension MTLCommandBuffer {

    @available(iOS 12.0, macOS 10.14, *)
    func compute(dispatch: MTLDispatchType,
                 _ commands: (MTLComputeCommandEncoder) throws -> Void) rethrows {
        guard let encoder = self.makeComputeCommandEncoder(dispatchType: dispatch)
        else { return }

        do { try commands(encoder) }
        catch {
            encoder.endEncoding()
            throw error
        }
        
        encoder.endEncoding()
    }

    func compute(_ commands: (MTLComputeCommandEncoder) throws -> Void) rethrows {
        guard let encoder = self.makeComputeCommandEncoder()
        else { return }

        do { try commands(encoder) }
        catch {
            encoder.endEncoding()
            throw error
        }
        
        encoder.endEncoding()
    }

    func blit(_ commands: (MTLBlitCommandEncoder) throws -> Void) rethrows {
        guard let encoder = self.makeBlitCommandEncoder()
        else { return }

        do { try commands(encoder) }
        catch {
            encoder.endEncoding()
            throw error
        }
        
        encoder.endEncoding()
    }
    
    func render(descriptor: MTLRenderPassDescriptor,
                _ commands: (MTLRenderCommandEncoder) throws -> Void) rethrows {
        guard let encoder = self.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }
        
        do { try commands(encoder) }
        catch {
            encoder.endEncoding()
            throw error
        }

        encoder.endEncoding()
    }
}
