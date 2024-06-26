#if targetEnvironment(simulator)

import MetalComputeTools
import XCTest

final class IntegralImageTests: XCTestCase {
    // MARK: - Properties

    var context: MTLContext!
    var integralImageFloat: IntegralImage!
    var source: MTLTexture!
    var destination: MTLTexture!
    var expectedResult: [Float32]!

    // MARK: - Setup

    override func setUpWithError() throws {
        self.context = try .init(bundle: .module)
        self.integralImageFloat = try .init(
            context: self.context,
            scalarType: .float
        )
        self.source = try self.context.texture(
            width: 4,
            height: 4,
            pixelFormat: .r32Float,
            options: .storageModeShared,
            usage: .shaderRead
        )
        self.destination = try self.context.texture(
            width: 4,
            height: 4,
            pixelFormat: .r32Float,
            options: .storageModeShared,
            usage: [.shaderRead, .shaderRead]
        )

        let sourceValues = [Float32](repeating: 0.1, count: 16)
        sourceValues.withUnsafeBufferPointer {
            if let baseAddress = $0.baseAddress {
                self.source.replace(
                    region: self.source.region,
                    mipmapLevel: 0,
                    withBytes: baseAddress,
                    bytesPerRow: MemoryLayout<Float32>.stride * 4
                )
            }
        }

        self.expectedResult = [Float32](repeating: 0, count: 16)
        for row in 0 ..< 4 {
            var previousValue: Float32 = 0
            for column in 0 ..< 4 {
                let position = row * 4 + column
                let currentValue = sourceValues[position]
                let resulValue = currentValue + previousValue
                self.expectedResult[position] = resulValue
                previousValue = resulValue
            }
        }
        for column in 0 ..< 4 {
            var previousValue: Float32 = 0
            for row in 0 ..< 4 {
                let position = row * 4 + column
                let currentValue = self.expectedResult[position]
                let resulValue = currentValue + previousValue
                self.expectedResult[position] = resulValue
                previousValue = resulValue
            }
        }
    }

    // MARK: - Testing

    func testIntegralImage() async throws {
        try await self.context.scheduleAsync { commandBuffer in
            self.integralImageFloat(
                source: self.source,
                destination: self.destination,
                in: commandBuffer
            )
        }

        var result = [Float32](repeating: 0, count: 16)
        result.withUnsafeMutableBytes {
            if let baseAddress = $0.baseAddress {
                self.destination.getBytes(
                    baseAddress,
                    bytesPerRow: MemoryLayout<Float32>.stride * 4,
                    from: self.destination.region,
                    mipmapLevel: 0
                )
            }
        }
        XCTAssertEqual(self.expectedResult, result)
    }
}

#endif
