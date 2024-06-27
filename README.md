# MetalTools

[![Platform Compatibility](https://img.shields.io/badge/Platforms-iOS%20|%20macOS-brightgreen)](https://swift.org/platforms/)
[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)

<p align="left">
    <img src="Media/MetalTools.png", width="120">
</p>

## Description

MetalTools provides a convenient, Swifty way of working with Metal. This library is heavily used in computer vision startups [ZERO10](https://zero10.ar) and [Prisma](https://prisma-ai.com).

## Usage

### Dispatch command buffers in both sync/async manner

See how you can group encodings with Swift closures.

```swift
self.context.scheduleAndWait { buffer in
    buffer.compute { encoder in
      // compute command encoding logic
    }

    buffer.blit { encoder in
      // blit command encoding logic
    }
}
```

### Easily create textures from CGImage

```swift
let texture = try context.texture(
    from: cgImage,
    usage: [.shaderRead, .shaderWrite]
)
```

### Load a compute pipeline state for a function that sits in a framework

```swift
let library = context.shaderLibrary(for: Foo.self)
let computePipelineState = try lib.computePipelineState(function: "brightness")
```

### Allocate buffer by value type

```swift
let buffer = context.buffer(
    for: InstanceUniforms.self,
    count: 99,
    options: .storageModeShared
)
```

### Serialize and deserialize MTLTexture 

```swift
let encoder = JSONEncoder()
let data = try encoder.encode(texture.codable())

let decoder = JSONDecoder()
let decodableTexture = try decoder.decode(MTLTextureCodableBox.self, from: data)
let decodedTexture = try decodableTexture.texture(device: self.context.device)
```

### Setup blending mode in render passes

```swift
let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
renderPipelineDescriptor.colorAttachments[0].setup(blending: .alpha)
```

### Other things

- Create multi-sample render target pairs
- Create textures
- Create depth buffers
- Create depth/stencil states
- [Lots of ready-to-use compute kernels](Sources/MetalComputeTools/Kernels)
- [A couple of simple geometry renderers](Sources/MetalRenderingTools/Renderers)
- etc.

## License

MetalTools is licensed under [MIT license](LICENSE).
