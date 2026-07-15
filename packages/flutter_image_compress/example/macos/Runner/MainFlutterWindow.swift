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
            let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any]
      else {
        result([String]())
        return
      }
      // Same shape as the iOS helper: keys from every metadata sub-dict we
      // care about, prefixed with the container name so tests can assert
      // survival of both EXIF-side keys (DateTimeOriginal) and TIFF-side
      // keys (DateTime on iOS screenshots).
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
