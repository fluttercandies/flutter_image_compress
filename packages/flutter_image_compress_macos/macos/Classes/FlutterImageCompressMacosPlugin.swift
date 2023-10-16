import Cocoa
import FlutterMacOS

class Logger {

  static var isShowLog = false

  static func showLog(show: Bool) {
    isShowLog = show
  }

  static func log(msg: String) {
    NSLog("\(msg)")
  }
}

public class FlutterImageCompressMacosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_image_compress", binaryMessenger: registrar.messenger)
    let instance = FlutterImageCompressMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handleResult(_ args: Any?, _ result: @escaping FlutterResult) -> Compressor? {
    let params = args as! Dictionary<String, Any>

    let haveList = params.contains { key, value in
      key == "list"
    }

    if (haveList) {
      let data = params["list"] as! FlutterStandardTypedData
      let nsData = data.data
      guard let image = NSImage(data: nsData) else {
        result(FlutterError(code: "Incoming byte arrays can't be converted to image.", message: nil, details: nil))
        return nil
      }
      return Compressor(image: image)
    }

    let havePath = params.contains { key, value in
      key == "path"
    }

    if (havePath) {
      let path = params["path"] as! String
      guard let image = NSImage(contentsOfFile: path) else {
        result(FlutterError(code: "Incoming file can't be converted to image.", message: nil, details: nil))
        return nil
      }
      return Compressor(image: image)
    }

    result(FlutterError(code: "The incoming parameters do not contain image.", message: nil, details: nil))

    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    let args = call.arguments

    switch method {
    case "showLog":
      Logger.showLog(show: args as! Bool)
    case "compressAndGetFile":
      let dstPath = (args as! Dictionary<String, Any>)["targetPath"] as! String
      handleResult(args, result)?.compressToPath(result, dstPath)
      break
    case "compressWithFile":
      handleResult(args, result)?.compressToBytes(result)
      break
    case "compressWithList":
      handleResult(args, result)?.compressToBytes(result)
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}


class Compressor {

  let image: NSImage

  init(image: NSImage) {
    self.image = image
  }

  func compressToPath(_ result: @escaping (Any?) -> (), _ path: String) {

  }

  func compressToBytes(_ result: @escaping (Any?) -> ()) {

  }

}