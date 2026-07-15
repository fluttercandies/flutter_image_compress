import Flutter
import UIKit
import ImageIO

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    Self.registerTestHelperChannel(registry: engineBridge.pluginRegistry)
  }

  private static func registerTestHelperChannel(registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "TestHelper") else { return }
    let channel = FlutterMethodChannel(
      name: "flutter_image_compress/test",
      binaryMessenger: registrar.messenger()
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
      guard let src = CGImageSourceCreateWithData(typed.data as CFData, nil),
            let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
      else {
        result([String]())
        return
      }
      // Return keys from every metadata sub-dict we care about, prefixed with
      // the container name so tests can assert survival of both EXIF-side
      // keys (DateTimeOriginal — #114) and TIFF-side keys (DateTime on iOS
      // screenshots — #168). SYMetadata's typed model used to drop keys not
      // modeled by its properties, so this helper walks the raw dictionary
      // directly.
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
      result(keys)
    }
  }
}
