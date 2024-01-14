// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "metal-tools",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "MetalTools",
            targets: ["MetalTools"]
        ),
        .library(
            name: "MetalComputeTools",
            targets: ["MetalComputeTools"]
        ),
        .library(
            name: "MetalRenderingTools",
            targets: ["MetalRenderingTools"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/SwiftGFX/SwiftMath.git",
            .upToNextMajor(from: "3.3.1")
        )
    ],
    targets: [
        .target(name: "MetalTools"),
        .target(
            name: "MetalComputeToolsSharedTypes",
            publicHeadersPath: "."
        ),
        .target(
            name: "MetalComputeTools",
            dependencies: [
                .target(name: "MetalComputeToolsSharedTypes"),
                .target(name: "MetalTools"),
                .product(
                    name: "SwiftMath",
                    package: "SwiftMath"
                )
            ],
            resources: [
                .process("Kernels/BitonicSort/BitonicSort.metal"),
                .process("Kernels/EuclideanDistance/EuclideanDistance.metal"),
                .process("Kernels/LookUpTable/LookUpTable.metal"),
                .process("Kernels/MaskGuidedBlur/MaskGuidedBlur.metal"),
                .process("Kernels/QuantizeDistanceField/QuantizeDistanceField.metal"),
                .process("Kernels/RGBAToYCbCr/RGBAToYCbCr.metal"),
                .process("Kernels/StdMeanNormalization/StdMeanNormalization.metal"),
                .process("Kernels/TextureAddConstant/TextureAddConstant.metal"),
                .process("Kernels/TextureAffineCrop/TextureAffineCrop.metal"),
                .process("Kernels/TextureCopy/TextureCopy.metal"),
                .process("Kernels/TextureDifferenceHighlight/TextureDifferenceHighlight.metal"),
                .process("Kernels/TextureDivideByConstant/TextureDivideByConstant.metal"),
                .process("Kernels/TextureInterpolation/TextureInterpolation.metal"),
                .process("Kernels/TextureMask/TextureMask.metal"),
                .process("Kernels/TextureMaskedMix/TextureMaskedMix.metal"),
                .process("Kernels/TextureMax/TextureMax.metal"),
                .process("Kernels/TextureMean/TextureMean.metal"),
                .process("Kernels/TextureMin/TextureMin.metal"),
                .process("Kernels/TextureMix/TextureMix.metal"),
                .process("Kernels/TextureMultiplyAdd/TextureMultiplyAdd.metal"),
                .process("Kernels/TextureResize/TextureResize.metal"),
                .process("Kernels/TextureWeightedMix/TextureWeightedMix.metal"),
                .process("Kernels/YCbCrToRGBA/YCbCrToRGBA.metal")
            ]
        ),
        .target(
            name: "MetalComputeToolsTestsResources",
            path: "Tests/MetalComputeToolsTestsResources",
            resources: [.copy("Shared")]
        ),
        .testTarget(
            name: "MetalComputeToolsTests",
            dependencies: [
                .target(name: "MetalComputeTools"),
                .target(name: "MetalComputeToolsTestsResources")
            ],
            resources: [.process("Shaders/Shaders.metal")]
        ),
        .target(
            name: "MetalRenderingToolsSharedTypes",
            publicHeadersPath: "."
        ),
        .target(
            name: "MetalRenderingTools",
            dependencies: [
                .target(name: "MetalRenderingToolsSharedTypes"),
                .target(name: "MetalComputeTools")
            ],
            resources: [
                .process("Renderers/Common/Common.metal"),
                .process("Renderers/LinesRenderer/LinesRenderer.metal"),
                .process("Renderers/MaskRenderer/MaskRenderer.metal"),
                .process("Renderers/PointsRenderer/PointsRenderer.metal"),
                .process("Renderers/RectangleRender/RectangleRender.metal"),
                .process("Renderers/SimpleGeometryRender/SimpleGeometryRender.metal"),
                .process("Renderers/TextRender/TextRender.metal"),
                .copy("Resources/HelveticaNeue.mtlfontatlas")
            ]
        )
    ]
)
