import Cocoa
import FlutterMacOS
import ImageIO

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    Self.registerTestHelperChannel(controller: flutterViewController)

    super.awakeFromNib()
  }

  // Test-only channel: mirrors the iOS AppDelegate helper so the
  // integration_test suite can assert EXIF preservation on macOS.
  private static func registerTestHelperChannel(controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "flutter_image_compress/test",
      binaryMessenger: controller.engine.binaryMessenger
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
