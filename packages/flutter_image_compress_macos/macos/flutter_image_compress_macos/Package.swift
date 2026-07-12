// swift-tools-version: 5.9

import PackageDescription

let packageName = "flutter_image_compress_macos"

let package = Package(
  name: packageName,
  platforms: [
    .macOS("10.15"),
  ],
  products: [
    .library(name: "flutter-image-compress-macos", targets: [packageName]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: packageName
    ),
  ]
)
