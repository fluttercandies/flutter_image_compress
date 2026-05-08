// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_image_compress_common",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "flutter-image-compress-common", targets: ["flutter_image_compress_common"])
    ],
    dependencies: [
        .package(url: "https://github.com/Mantle/Mantle.git", from: "2.2.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.19.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.14.0"),
    ],
    targets: [
        .target(
            name: "flutter_image_compress_common",
            dependencies: [
                .product(name: "Mantle", package: "Mantle"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder"),
            ],
            publicHeadersPath: ""
        )
    ]
)
