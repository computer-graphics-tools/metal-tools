import Metal

public extension MTLDevice {
    
    func texture(from cgImage: CGImage, srgb: Bool = false, usage: MTLTextureUsage = []) throws -> MTLTexture {
        
        // AlphaFirst – the alpha channel is next to the red channel, argb and bgra are both alpha first formats.
        // AlphaLast – the alpha channel is next to the blue channel, rgba and abgr are both alpha last formats.
        // LittleEndian – blue comes before red, bgra and abgr are little endian formats.
        // Little endian ordered pixels are BGR (BGRX, XBGR, BGRA, ABGR, BGR).
        // BigEndian – red comes before blue, argb and rgba are big endian formats.
        // Big endian ordered pixels are RGB (XRGB, RGBX, ARGB, RGBA, RGB).
        
        // Valid parameters for RGB color space model are:
        // 16  bits per pixel, 5  bits per component, kCGImageAlphaNoneSkipFirst
        // 32  bits per pixel, 8  bits per component, kCGImageAlphaNoneSkipFirst
        // 32  bits per pixel, 8  bits per component, kCGImageAlphaNoneSkipLast
        // 32  bits per pixel, 8  bits per component, kCGImageAlphaPremultipliedFirst
        // 32  bits per pixel, 8  bits per component, kCGImageAlphaPremultipliedLast
        // 32  bits per pixel, 10 bits per component, kCGImageAlphaNone|kCGImagePixelFormatRGBCIF10
        // 64  bits per pixel, 16 bits per component, kCGImageAlphaPremultipliedLast
        // 64  bits per pixel, 16 bits per component, kCGImageAlphaNoneSkipLast
        // 64  bits per pixel, 16 bits per component, kCGImageAlphaPremultipliedLast|kCGBitmapFloatComponents
        // 64  bits per pixel, 16 bits per component, kCGImageAlphaNoneSkipLast|kCGBitmapFloatComponents
        // 128 bits per pixel, 32 bits per component, kCGImageAlphaPremultipliedLast|kCGBitmapFloatComponents
        // 128 bits per pixel, 32 bits per component, kCGImageAlphaNoneSkipLast|kCGBitmapFloatComponents
        
        guard let colorSpace = cgImage.colorSpace
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        
        let pixelFormat: MTLPixelFormat
        var optionalCGContext: CGContext?
        
        if colorSpace.model == .monochrome {
            pixelFormat = .r8Unorm
            optionalCGContext = CGContext(
                data: nil,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: 8,
                bytesPerRow: cgImage.width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGImageByteOrderInfo.orderDefault.rawValue
            )
        } else if colorSpace.model == .rgb {
            pixelFormat = srgb ? .rgba8Unorm_srgb : .rgba8Unorm
            optionalCGContext = CGContext(
                data: nil,
                width: cgImage.width,
                height: cgImage.height,
                bitsPerComponent: 8,
                bytesPerRow: cgImage.width * 4,
                space: srgb ? CGColorSpace(name: CGColorSpace.sRGB)! : CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            )
        } else { throw MetalError.MTLDeviceError.textureCreationFailed }
        
        optionalCGContext?.draw(
            cgImage,
            in: CGRect(
                origin: .zero,
                size: CGSize(
                    width: cgImage.width,
                    height: cgImage.height
                )
            )
        )
        
        guard let cgContext = optionalCGContext,
              let baseAddress = cgContext.data
        else { throw MetalError.MTLDeviceError.textureCreationFailed }
        
        let texture = try self.texture(
            width: cgImage.width,
            height: cgImage.height,
            pixelFormat: pixelFormat,
            options: [.cpuCacheModeWriteCombined],
            usage: usage
        )
        
        texture.replace(
            region: texture.region,
            mipmapLevel: 0,
            withBytes: baseAddress,
            bytesPerRow: cgContext.bytesPerRow
        )
        
        return texture
    }
    
}
