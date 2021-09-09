// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "metal-tools",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "MetalTools",
                 targets: ["MetalTools"]),
    ],
    targets: [
        .target(name: "MetalTools")
    ]
)
