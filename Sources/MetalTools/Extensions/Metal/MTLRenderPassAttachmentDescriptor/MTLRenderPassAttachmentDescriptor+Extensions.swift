import Metal

extension MTLRenderPassAttachmentDescriptor {
    /// Enum representing different store actions for render pass attachments.
    enum StoreAction {
        /// Don't care about the contents after rendering.
        case dontCare(texture: MTLTexture)
        /// Store the results of rendering.
        case store(texture: MTLTexture)
        /// Resolve a multisampled texture into a non-multisampled texture.
        case multisampleResolve(multisamplingTexture: MTLTexture, resolveTexture: MTLTexture)
    }
}

extension MTLRenderPassColorAttachmentDescriptor {
    /// Enum representing different load actions for color attachments.
    enum LoadAction {
        /// Don't care about the initial contents.
        case dontCare
        /// Load the existing contents.
        case load
        /// Clear the attachment with a specified color.
        case clear(color: MTLClearColor)
    }

    /// Sets up the color attachment with specified load and store actions.
    ///
    /// - Parameters:
    ///   - loadAction: The action to perform when loading the attachment.
    ///   - storeAction: The action to perform when storing the attachment.
    func setup(loadAction: LoadAction, storeAction: StoreAction) {
        switch loadAction {
        case let .clear(clearColor):
            self.loadAction = .clear
            self.clearColor = clearColor
        case .dontCare:
            self.loadAction = .dontCare
        case .load:
            self.loadAction = .load
        }

        switch storeAction {
        case let .dontCare(texture: texture):
            self.storeAction = .dontCare
            self.texture = texture
            self.resolveTexture = nil
        case let .store(texture):
            self.storeAction = .store
            self.texture = texture
            self.resolveTexture = nil
        case let .multisampleResolve(texture, resolveTexture):
            self.storeAction = .multisampleResolve
            self.texture = texture
            self.resolveTexture = resolveTexture
        }
    }
}

extension MTLRenderPassDepthAttachmentDescriptor {
    /// Enum representing different load actions for depth attachments.
    enum LoadAction {
        /// Don't care about the initial contents.
        case dontCare
        /// Load the existing contents.
        case load
        /// Clear the attachment with a specified depth value.
        case clear(clearDepth: Double)
    }

    /// Sets up the depth attachment with specified load and store actions.
    ///
    /// - Parameters:
    ///   - loadAction: The action to perform when loading the attachment.
    ///   - storeAction: The action to perform when storing the attachment.
    func setup(loadAction: LoadAction, storeAction: StoreAction) {
        switch loadAction {
        case let .clear(clearDepth):
            self.loadAction = .clear
            self.clearDepth = clearDepth
        case .dontCare:
            self.loadAction = .dontCare
        case .load:
            self.loadAction = .load
        }

        switch storeAction {
        case let .dontCare(texture: texture):
            self.storeAction = .dontCare
            self.texture = texture
            self.resolveTexture = nil
        case let .store(texture):
            self.storeAction = .store
            self.texture = texture
            self.resolveTexture = nil
        case let .multisampleResolve(multisamplingTexture, resolveTexture):
            self.storeAction = .multisampleResolve
            self.texture = multisamplingTexture
            self.resolveTexture = resolveTexture
        }
    }
}
