// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_image_compress_common",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "flutter-image-compress-common", targets: ["flutter_image_compress_common"])
    ],
    dependencies: [
        .package(url: "https://github.com/Mantle/Mantle", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/SDWebImage/SDWebImage", .upToNextMajor(from: "5.21.1")),
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder", .upToNextMajor(from: "0.14.6")),
    ],
    targets: [
        .target(
            name: "flutter_image_compress_common",
            dependencies: [
                .product(name: "Mantle", package: "Mantle"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder")
            ],
            cSettings: [
                .headerSearchPath("include/flutter_image_compress_common")
            ]
        )
    ]
)
