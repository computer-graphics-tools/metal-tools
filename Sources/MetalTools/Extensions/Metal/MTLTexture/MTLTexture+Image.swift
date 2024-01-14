import Accelerate
import CoreGraphics
import Foundation
import MetalKit
import MetalPerformanceShaders

public extension MTLTexture {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    typealias NSUIImage = UIImage
    #elseif os(macOS) && !targetEnvironment(macCatalyst)
    typealias NSUIImage = NSImage
    #endif

    func cgImage(colorSpace: CGColorSpace? = nil) throws -> CGImage {
        guard self.isAccessibleOnCPU
        else { throw MetalError.MTLTextureError.imageCreationFailed }

        switch self.pixelFormat {
        case .a8Unorm, .r8Unorm, .r8Uint:
            let rowBytes = self.width
            let length = rowBytes * self.height

            let rgbaBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
            defer { rgbaBytes.deallocate() }
            self.getBytes(
                rgbaBytes,
                bytesPerRow: rowBytes,
                from: self.region,
                mipmapLevel: 0
            )

            let colorScape = colorSpace ?? CGColorSpaceCreateDeviceGray()
            let bitmapInfo = CGBitmapInfo(rawValue: self.pixelFormat == .a8Unorm
                ? CGImageAlphaInfo.alphaOnly.rawValue
                : CGImageAlphaInfo.none.rawValue)
            guard let data = CFDataCreate(
                nil,
                rgbaBytes,
                length
            ),
                let dataProvider = CGDataProvider(data: data),
                let cgImage = CGImage(
                    width: self.width,
                    height: self.height,
                    bitsPerComponent: 8,
                    bitsPerPixel: 8,
                    bytesPerRow: rowBytes,
                    space: colorScape,
                    bitmapInfo: bitmapInfo,
                    provider: dataProvider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent
                )
            else { throw MetalError.MTLTextureError.imageCreationFailed }

            return cgImage
        case .bgra8Unorm, .bgra8Unorm_srgb:
            // read texture as byte array
            let rowBytes = self.width * 4
            let length = rowBytes * self.height
            let bgraBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
            let rgbaBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
            defer { bgraBytes.deallocate(); rgbaBytes.deallocate() }
            self.getBytes(
                bgraBytes,
                bytesPerRow: rowBytes,
                from: self.region,
                mipmapLevel: 0
            )

            // use Accelerate framework to convert from BGRA to RGBA

            var bgraBuffer = vImage_Buffer(
                data: bgraBytes,
                height: vImagePixelCount(self.height),
                width: vImagePixelCount(self.width),
                rowBytes: rowBytes
            )
            var rgbaBuffer = vImage_Buffer(
                data: rgbaBytes,
                height: vImagePixelCount(self.height),
                width: vImagePixelCount(self.width),
                rowBytes: rowBytes
            )
            let map: [UInt8] = [2, 1, 0, 3]
            vImagePermuteChannels_ARGB8888(
                &bgraBuffer,
                &rgbaBuffer,
                map,
                0
            )

            // create CGImage with RGBA Flipped Bytes
            let colorScape = colorSpace ?? CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            guard let data = CFDataCreate(
                nil,
                rgbaBytes,
                length
            ),
                let dataProvider = CGDataProvider(data: data),
                let cgImage = CGImage(
                    width: self.width,
                    height: self.height,
                    bitsPerComponent: 8,
                    bitsPerPixel: 32,
                    bytesPerRow: rowBytes,
                    space: colorScape,
                    bitmapInfo: bitmapInfo,
                    provider: dataProvider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent
                )
            else { throw MetalError.MTLTextureError.imageCreationFailed }

            return cgImage
        case .rgba8Unorm, .rgba8Unorm_srgb:
            let rowBytes = self.width * 4
            let length = rowBytes * self.height

            let rgbaBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
            defer { rgbaBytes.deallocate() }
            self.getBytes(
                rgbaBytes,
                bytesPerRow: rowBytes,
                from: self.region,
                mipmapLevel: 0
            )

            let colorScape = colorSpace ?? CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            guard let data = CFDataCreate(
                nil,
                rgbaBytes,
                length
            ),
                let dataProvider = CGDataProvider(data: data),
                let cgImage = CGImage(
                    width: self.width,
                    height: self.height,
                    bitsPerComponent: 8,
                    bitsPerPixel: 32,
                    bytesPerRow: rowBytes,
                    space: colorScape,
                    bitmapInfo: bitmapInfo,
                    provider: dataProvider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent
                )
            else { throw MetalError.MTLTextureError.imageCreationFailed }

            return cgImage
        default: throw MetalError.MTLTextureError.imageIncompatiblePixelFormat
        }
    }

    func image(colorSpace: CGColorSpace? = nil) throws -> NSUIImage {
        let cgImage = try self.cgImage(colorSpace: colorSpace)
        #if os(iOS)
        return UIImage(cgImage: cgImage)
        #elseif os(macOS)
        return NSImage(
            cgImage: cgImage,
            size: CGSize(
                width: cgImage.width,
                height: cgImage.height
            )
        )
        #endif
    }
}
