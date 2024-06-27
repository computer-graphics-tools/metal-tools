import Foundation
import Metal

private enum MTLContextCodingUserInfoKey {
    static let `default` = CodingUserInfoKey(rawValue: "MetalTools.MTLContext")!
}

/// A protocol for types that can hold coding user info.
public protocol CodingUserInfoHolder {
    var userInfo: [CodingUserInfoKey : Any] { get set }
}

/// A protocol for types that can hold an MTLContext in their coding user info.
public protocol CodingMTLContextHolder: CodingUserInfoHolder {
    /// Inserts an MTLContext into the userInfo dictionary.
    ///
    /// - Parameter context: The MTLContext to insert.
    mutating func insertContext(_ context: MTLContext)
}

public extension Decoder {
    /// Retrieves the MTLContext from the decoder's userInfo.
    ///
    /// - Returns: The MTLContext if present, nil otherwise.
    func obtainContext() -> MTLContext? {
        self.userInfo[MTLContextCodingUserInfoKey.default] as? MTLContext
    }
}

public extension CodingMTLContextHolder {
    /// Default implementation for inserting an MTLContext into the userInfo dictionary.
    ///
    /// - Parameter context: The MTLContext to insert.
    mutating func insertContext(_ context: MTLContext) {
        self.userInfo[MTLContextCodingUserInfoKey.default] = context
    }
}

// Conformance to CodingMTLContextHolder
extension JSONDecoder: CodingMTLContextHolder {}
extension PropertyListDecoder: CodingMTLContextHolder {}
