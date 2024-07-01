import Metal.MTLHeap

/// Aligns the given size up to the nearest multiple of the specified alignment.
///
/// This function assumes that `align` is a power of two.
///
/// - Parameters:
///   - size: The size to be aligned.
///   - align: The alignment, which must be a power of two.
/// - Returns: The size aligned up to the nearest multiple of `align`.
///
/// In debug mode, a precondition ensures that `align` is a power of two.
public func alignUp(size: Int, align: Int) -> Int {
    #if DEBUG
    precondition(((align-1) & align) == 0, "Align must be a power of two")
    #endif

    let alignmentMask = align - 1
    return (size + alignmentMask) & ~alignmentMask
}

public extension MTLSizeAndAlign {

    /// Combines the current MTLSizeAndAlign instance with another, taking into account their alignments.
    ///
    /// - Parameter sizeAndAlign: The other MTLSizeAndAlign instance to combine with.
    /// - Returns: A new MTLSizeAndAlign instance with combined size and the required alignment.
    ///
    /// The combined size is calculated by aligning both sizes to the maximum alignment
    /// of the two instances and then summing them.
    func combined(with sizeAndAlign: MTLSizeAndAlign) -> MTLSizeAndAlign {
        let requiredAlignment = max(self.align, sizeAndAlign.align)
        let selfAligned = alignUp(size: self.size, align: requiredAlignment)
        let otherAligned = alignUp(size: sizeAndAlign.size, align: requiredAlignment)

        return MTLSizeAndAlign(size: selfAligned + otherAligned, align: requiredAlignment)
    }
}

public extension Sequence where Element == MTLTextureDescriptor {

    /// Computes the combined heap size and alignment for a sequence of MTLTextureDescriptors on a given device.
    ///
    /// - Parameter device: The MTLDevice to use for computing the heap size and alignment.
    /// - Returns: A MTLSizeAndAlign instance representing the combined size and alignment for the heap.
    ///
    /// This method reduces the sequence of MTLTextureDescriptors into a single MTLSizeAndAlign
    /// by computing the size and alignment for each descriptor and combining them.
    func heapSizeAndAlignCombined(on device: MTLDevice) -> MTLSizeAndAlign {
        self.reduce(MTLSizeAndAlign(size: 0, align: 0)) { result, descriptor in
            let sizeAndAlign = device.heapTextureSizeAndAlign(descriptor: descriptor)
            return result.combined(with: sizeAndAlign)
        }
    }
}
