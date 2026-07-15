// Shared test-only helper channel for iOS + macOS example Runners.
//
// The plugin's public MethodChannel intentionally does not expose an EXIF
// reader — that would be a new API surface unrelated to compression. But
// the integration tests still need to verify what metadata the plugin's
// output actually contains. This file registers a private-to-example
// channel (`flutter_image_compress/test`) that walks the CGImageSource
// property tree for the passed-in bytes.
//
// Both `example/ios/Runner/AppDelegate.swift` and
// `example/macos/Runner/MainFlutterWindow.swift` reference this single
// file (via a relative Xcode file reference), so the reader logic lives
// in exactly one place regardless of platform. ImageIO is a Darwin
// framework available on both iOS and macOS, so the implementation is
// identical modulo the FlutterBinaryMessenger type on either side.

import Foundation
import ImageIO
#if canImport(Flutter)
  import Flutter
#elseif canImport(FlutterMacOS)
  import FlutterMacOS
#endif

enum ExifTestHelper {
  /// Register the `flutter_image_compress/test` channel on the given
  /// binary messenger. Call from the Runner's plugin-registration site
  /// on both iOS and macOS.
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "flutter_image_compress/test",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "readExifKeys" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let typed = call.arguments as? FlutterStandardTypedData else {
        result([String]())
        return
      }
      result(readExifKeys(from: typed.data))
    }
  }

  /// Walk every EXIF/TIFF/GPS/IPTC/PNG sub-dict in the image's property
  /// tree and return the keys prefixed with the container name. Tests
  /// use the prefix to distinguish e.g. `exif:DateTimeOriginal` from
  /// `tiff:DateTime` — the same key name can live in more than one
  /// container, and both are load-bearing for keepExif regressions.
  private static func readExifKeys(from data: Data) -> [String] {
    guard let src = CGImageSourceCreateWithData(data as CFData, nil),
          let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
    else {
      return []
    }
    var keys: [String] = []
    let dicts: [(String, CFString)] = [
      ("exif", kCGImagePropertyExifDictionary),
      ("tiff", kCGImagePropertyTIFFDictionary),
      ("gps", kCGImagePropertyGPSDictionary),
      ("iptc", kCGImagePropertyIPTCDictionary),
      ("png", kCGImagePropertyPNGDictionary),
    ]
    for (prefix, dictKey) in dicts {
      guard let sub = props[dictKey] as? [CFString: Any] else { continue }
      for key in sub.keys {
        keys.append("\(prefix):\(key as String)")
      }
    }
    return keys
  }
}
