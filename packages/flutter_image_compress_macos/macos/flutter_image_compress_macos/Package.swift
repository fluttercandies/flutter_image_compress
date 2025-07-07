// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_image_compress_macos",
    platforms: [
        .macOS("10.15"),
    ],
    products: [
        .library(name: "flutter-image-compress-macos", targets: ["flutter_image_compress_macos"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_image_compress_macos",
            dependencies: []
        )
    ]
)
