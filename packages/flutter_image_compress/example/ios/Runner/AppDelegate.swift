import Flutter
import UIKit

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
    // Test-only helper channel implementation lives at ../../shared/
    // and is added to both Runner projects via a relative file reference.
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TestHelper") else { return }
    ExifTestHelper.register(with: registrar.messenger())
  }
}
