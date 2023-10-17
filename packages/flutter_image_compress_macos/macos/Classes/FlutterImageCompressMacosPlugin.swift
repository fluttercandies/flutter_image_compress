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
      return Compressor(image: image, params: params)
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
      return Compressor(image: image, params: params)
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
  let params: Dictionary<String, Any>

  init(image: NSImage, params: Dictionary<String, Any>) {
    self.image = image
    self.params = params
  }

  func compress() -> NSImage {
    let rotate = params["rotate"] as! Int

    let minWidth = params["minWidth"] as! Int
    let minHeight = params["minHeight"] as! Int

    let srcWidth = image.size.width
    let srcHeight = image.size.height

    let ratio = srcWidth / srcHeight
    let maxRatio = CGFloat(minWidth) / CGFloat(minHeight)
    var scale = 1.0

    if (ratio < maxRatio) {
      scale = CGFloat(minWidth) / srcWidth
    } else {
      scale = CGFloat(minHeight) / srcHeight
    }

    let targetWidth = (srcWidth * scale).rounded()
    let targetHeight = (srcHeight * scale).rounded()

    let targetSize = NSMakeSize(targetWidth, targetHeight)
    let targetRect = NSMakeRect(0, 0, targetWidth, targetHeight)

    let targetImage = NSImage(size: targetSize)
    targetImage.lockFocus()

    let context = NSGraphicsContext.current?.cgContext
    context?.interpolationQuality = .high
    context?.setFillColor(NSColor.white.cgColor)
    context?.fill(targetRect)
    context?.draw(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: targetRect)

    // rotate
    if (rotate != 0) {
      let rotateAngle = CGFloat(rotate) * CGFloat.pi / 180
      let rotateTransform = CGAffineTransform(rotationAngle: rotateAngle)
      context?.concatenate(rotateTransform)
    }

    targetImage.unlockFocus()

    return targetImage
  }

  func compressData(_ resultHandler: @escaping (Any?) -> ()) -> Data? {
    let resultImage = compress()
    let data = resultImage.tiffRepresentation

    let quality = params["quality"] as! Int
    let format = params["format"] as! Int
//    let keepExif = params["keepExif"] as! Bool
//    let inSampleSize = params["inSampleSize"] as! Int
//    let autoCorrectionAngle = params["autoCorrectionAngle"] as! Bool

    let outputFormat = CompressFormat.convertInt(type: format)

    if (outputFormat == .jpeg) {
      let compressQuality = CGFloat(quality) / 100
      let dictionary: [NSBitmapImageRep.PropertyKey: Any] = [
        .compressionFactor: compressQuality,
        .compressionMethod: 4,
      ]
      return NSBitmapImageRep(data: data!)!.representation(using: NSBitmapImageRep.FileType.jpeg, properties: dictionary)!
    } else if (outputFormat == .png) {
      return NSBitmapImageRep(data: data!)!.representation(using: NSBitmapImageRep.FileType.png, properties: [:])!
    }

    resultHandler(FlutterError(code: "The format cannot be converted", message: nil, details: nil))
    return nil
  }

  func compressToPath(_ result: @escaping (Any?) -> (), _ path: String) {
    if let data = compressData(result) {
      let fileManager = FileManager.default
      fileManager.createFile(atPath: path, contents: data, attributes: nil)
      result(path)
    }
  }

  func compressToBytes(_ result: @escaping (Any?) -> ()) {
    if let data = compressData(result) {
      result(FlutterStandardTypedData(bytes: data))
    }
  }

}

enum CompressFormat {
  case jpeg
  case png
  case heic
  case webp

  static func convertInt(type: Int) -> CompressFormat {
    switch (type) {
    case 0:
      return .jpeg
    case 1:
      return .png
    case 2:
      return .heic
    case 3:
      return .webp
    default:
      return .jpeg
    }
  }
}
