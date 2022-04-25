import Metal

@available(iOS 13.0, *)
public extension MTLContext {
    
    enum CaptureObject {
        case device
        case commandQueue
    }
    
    enum CaptureDestination {
        case gpuTraceDocument(url: URL)
        case developerTools
    }
    
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
    
    func stopCapture() {
        MTLCaptureManager.shared().stopCapture()
    }
    
}
