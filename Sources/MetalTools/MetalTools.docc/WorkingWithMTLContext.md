# Working with MTLContext

Learn how to use ``MTLContext`` to simplify your Metal workflow.

## Overview

``MTLContext`` is a central component of the MetalTools framework, designed to streamline Metal-based operations. It encapsulates an `MTLDevice` and an `MTLCommandQueue`, providing a unified interface for common Metal tasks.

## Creating an MTLContext

To start working with ``MTLContext``, you first need to create an instance. Here's how you can do it:

```swift
import MetalTools

do {
    let context = try MTLContext()
    // Use the context for further operations
} catch {
    print("Failed to create MTLContext: \(error)")
}
```

## Resource Creation

`MTLContext` provides convenient methods for creating Metal resources such as textures and buffers.

## Creating Textures

You can create textures easily using the ``MTLContext/texture(width:height:pixelFormat:options:usage:)`` method:

```
do {
    let texture = try context.texture(
        width: 512,
        height: 512,
        pixelFormat: .rgba8Unorm,
        usage: [.shaderRead, .renderTarget]
    )
    // Use the texture...
} catch {
    print("Failed to create texture: \(error)")
}
```

## Creating Buffers

To create buffers, use the ``MTLContext/buffer(for:count:options:)`` method:

```swift
struct Vertex {
    let position: SIMD3<Float>
    let color: SIMD4<Float>
}

do {
    let vertexBuffer = try context.buffer(for: Vertex.self, count: 100)
    // Use the buffer...
} catch {
    print("Failed to create buffer: \(error)")
}
```

## Command Scheduling

`MTLContext` simplifies command scheduling with methods that abstract away the complexities of working directly with command buffers.

### Synchronous Scheduling

For synchronous operations, use the ``MTLContext/scheduleAndWait(_:)`` method:

```swift
do {
    try context.scheduleAndWait { commandBuffer in
        // Encode your commands here
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        // ... set up your render pass ...
        renderEncoder?.endEncoding()
    }
} catch {
    print("Command scheduling failed: \(error)")
}
```

### Asynchronous Scheduling

For asynchronous operations, you can use the ``MTLContext/scheduleAsync(_:)`` method:

```swift
Task {
    do {
        let result = try await context.scheduleAsync { commandBuffer in
            // Encode your commands here
            // Return any result you need
        }
        print("Async operation completed with result: \(result)")
    } catch {
        print("Async command scheduling failed: \(error)")
    }
}
```

## Working with Libraries

``MTLContext`` provides methods for creating and working with Metal libraries:

```swift
do {
    let library = try context.library(from: URL(fileURLWithPath: "Shaders.metal"))
    let function = try library.makeFunction(name: "vertex_main")
    // Use the function to create a pipeline state...
} catch {
    print("Failed to create library or function: \(error)")
}
```

## Topics

### Creating Resources

``MTLContext/texture(width:height:pixelFormat:options:usage:)``
``MTLContext/buffer(for:count:options:)``

##Command Scheduling

``MTLContext/scheduleAndWait(_:)``
``MTLContext/schedule(_:)``
``MTLContext/scheduleAsync(_:)``

## Library Management

``MTLContext/library(from:options:)``