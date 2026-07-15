import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    // Test-only helper channel implementation lives at ../../shared/ and is
    // added to both Runner projects via a relative file reference.
    ExifTestHelper.register(with: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}
