import Metal

public extension MTLCommandBuffer {
    /// Encodes compute commands with a specified dispatch type.
    ///
    /// - Parameters:
    ///   - dispatch: The type of dispatch to use for the compute command encoder.
    ///   - commands: A closure that takes a `MTLComputeCommandEncoder` and encodes commands.
    /// - Throws: Rethrows any error thrown by the `commands` closure.
    func compute(
        dispatch: MTLDispatchType,
        _ commands: (MTLComputeCommandEncoder) throws -> Void
    ) rethrows {
        guard let encoder = self.makeComputeCommandEncoder(dispatchType: dispatch)
        else { return }

        do { try commands(encoder) }
        catch {
            encoder.endEncoding()
            throw error
        }

        encoder.endEncoding()
    }

    /// Encodes compute commands with the default dispatch type.
    ///
    /// - Parameter commands: A closure that takes a `MTLComputeCommandEncoder` and encodes commands.
    /// - Throws: Rethrows any error thrown by the `commands` closure.
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

    /// Encodes blit commands.
    ///
    /// - Parameter commands: A closure that takes a `MTLBlitCommandEncoder` and encodes commands.
    /// - Throws: Rethrows any error thrown by the `commands` closure.
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

    /// Encodes render commands.
    ///
    /// - Parameters:
    ///   - descriptor: The render pass descriptor to use for the render command encoder.
    ///   - commands: A closure that takes a `MTLRenderCommandEncoder` and encodes commands.
    /// - Throws: Rethrows any error thrown by the `commands` closure.
    func render(
        descriptor: MTLRenderPassDescriptor,
        _ commands: (MTLRenderCommandEncoder) throws -> Void
    ) rethrows {
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
