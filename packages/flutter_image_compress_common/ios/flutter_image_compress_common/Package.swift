// swift-tools-version: 5.9

import PackageDescription

let packageName = "flutter_image_compress_common"

let package = Package(
  name: packageName,
  platforms: [
    .iOS("9.0"),
  ],
  products: [
    .library(name: "flutter-image-compress-common", targets: [packageName]),
  ],
  dependencies: [
    .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.19.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder.git", from: "0.14.0"),
    .package(url: "https://github.com/Mantle/Mantle.git", from: "2.2.0"),
  ],
  targets: [
    .target(
      name: packageName,
      dependencies: [
        .product(name: "SDWebImage", package: "SDWebImage"),
        .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder"),
        .product(name: "Mantle", package: "Mantle"),
      ],
      cSettings: [
        .headerSearchPath("include/\(packageName)"),
      ]
    ),
  ]
)
