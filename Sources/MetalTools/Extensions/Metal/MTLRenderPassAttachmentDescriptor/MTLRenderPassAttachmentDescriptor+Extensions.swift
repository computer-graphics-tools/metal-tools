import Metal

extension MTLRenderPassAttachmentDescriptor {
    enum StoreAction {
        case dontCare(texture: MTLTexture)
        case store(texture: MTLTexture)
        case multisampleResolve(multisamplingTexture: MTLTexture, resolveTexture: MTLTexture)
    }
}

extension MTLRenderPassColorAttachmentDescriptor {
    enum LoadAction {
        case dontCare
        case load
        case clear(color: MTLClearColor)
    }

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
    enum LoadAction {
        case dontCare
        case load
        case clear(clearDepth: Double)
    }

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
