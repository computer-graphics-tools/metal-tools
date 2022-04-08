import Foundation
import Metal

private enum MTLContextCodingUserInfoKey {
    static let `default` = CodingUserInfoKey(rawValue: "MetalTools.MTLContext")!
}

public protocol CodingUserInfoHolder {
    var userInfo: [CodingUserInfoKey : Any] { get set }
}

public protocol CodingMTLContextHolder: CodingUserInfoHolder {
    mutating func insertContext(_ context: MTLContext)
}

public extension Decoder {
    func obtainContext() -> MTLContext? {
        self.userInfo[MTLContextCodingUserInfoKey.default] as? MTLContext
    }
}

public extension CodingMTLContextHolder {
    mutating func insertContext(_ context: MTLContext) {
        self.userInfo[MTLContextCodingUserInfoKey.default] = context
    }
}

extension JSONDecoder: CodingMTLContextHolder {}
extension PropertyListDecoder: CodingMTLContextHolder {}
