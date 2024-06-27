import Metal

public extension MTLContext {

    /// Enum representing the object to be captured.
    enum CaptureObject {
        case device
        case commandQueue
    }

    /// Enum representing the destination of the capture.
    enum CaptureDestination {
        case gpuTraceDocument(url: URL)
        case developerTools
    }

    /// Starts a capture session with the specified object and destination.
    ///
    /// - Parameters:
    ///   - object: The object to capture. Defaults to `.commandQueue`.
    ///   - destination: The destination for the capture output. Defaults to `.developerTools`.
    /// - Throws: An error if the capture session fails to start.
    ///
    /// This method configures and starts a capture session using the specified object and destination.
    /// The capture can be directed to either a GPU trace document or developer tools.
    func startCapture(
        object: CaptureObject = .commandQueue,
        destination: CaptureDestination = .developerTools
    ) throws {
        let captureDescriptor = MTLCaptureDescriptor()
        switch object {
        case .device:
            captureDescriptor.captureObject = self.device
        case .commandQueue:
            captureDescriptor.captureObject = self.commandQueue
        }
        switch destination {
        case let .gpuTraceDocument(url):
            captureDescriptor.destination = .gpuTraceDocument
            captureDescriptor.outputURL = url
        case .developerTools:
            captureDescriptor.destination = .developerTools
        }

        try MTLCaptureManager.shared().startCapture(with: captureDescriptor)
    }

    /// Stops the current capture session.
    ///
    /// This method stops any ongoing capture session.
    func stopCapture() {
        MTLCaptureManager.shared().stopCapture()
    }
}
