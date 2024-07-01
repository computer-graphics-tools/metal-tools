# ``MetalTools``

![MetalTools](metal-tools.png)

A Swift framework that simplifies working with Apple's Metal API.

MetalTools provides a set of extensions and utilities to make Metal programming more Swift-friendly and easier to use. It includes convenience methods for common tasks, abstractions for complex operations, and Swift-style error handling.

## Overview

MetalTools is built around the `MTLContext` class, which serves as a central point for Metal-related operations. It provides extensions for:

- Command queue management
- Device operations
- Texture and buffer creation
- Pipeline state management
- And more

## Topics

### Essentials

- <doc:WorkingWithMTLContext>

### Working with Command Queues

- ``MTLContext/scheduleAndWait(_:)``
- ``MTLContext/schedule(_:)``
- ``MTLContext/scheduleAsync(_:)``

### Device Operations

- ``MTLContext/texture(from:srgb:usage:)``
- ``MTLContext/buffer(for:count:options:)``
- ``MTLContext/library(from:options:)``
