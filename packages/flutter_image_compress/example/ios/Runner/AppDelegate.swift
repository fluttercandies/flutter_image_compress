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
            let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any],
            let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any]
      else {
        result([String]())
        return
      }
      result(exif.keys.map { $0 as String })
    }
  }
}
