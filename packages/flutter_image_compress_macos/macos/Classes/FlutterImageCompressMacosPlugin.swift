import Cocoa
import FlutterMacOS
import AVFoundation

class Logger {

  static var isShowLog = false

  static func showLog(show: Bool) {
    isShowLog = show
  }

  static func log(msg: String) {
    NSLog("\(msg)")
  }
}

class ImageSrc {
  let srcImage: CGImageSource
  let params: Dictionary<String, Any>

  init(srcImage: CGImageSource, params: Dictionary<String, Any>) {
    self.srcImage = srcImage
    self.params = params
  }

  func getSize() -> NSSize {
    let image = CGImageSourceCreateImageAtIndex(srcImage, 0, nil)

    let width = image?.width ?? 0
    let height = image?.height ?? 0

    let orientation = params[kCGImagePropertyOrientation as String] as? Int

    if (orientation == 3 || orientation == 6) {
      return NSMakeSize(CGFloat(height), CGFloat(width))
    }

    return NSMakeSize(CGFloat(width), CGFloat(height))
  }
}

public class FlutterImageCompressMacosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_image_compress", binaryMessenger: registrar.messenger)
    let instance = FlutterImageCompressMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func getImageSrc(params: Dictionary<String, Any>, sourceGetter: () -> CGImageSource?) -> ImageSrc? {
    let keepExif = params["keepExif"] as! Bool

    guard let source = sourceGetter() else {
      return nil
    }

    if (!keepExif) {
      return ImageSrc(srcImage: source, params: [String: Any]())
    }

    if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] {
      return ImageSrc(srcImage: source, params: properties)
    } else {
      return ImageSrc(srcImage: source, params: [String: Any]())
    }

  }

  func makeFlutterError(code: String = "The incoming parameters do not contain image.") -> FlutterError {
    FlutterError(code: code, message: nil, details: nil)
  }

  func handleResult(_ args: Any?, _ result: @escaping FlutterResult) -> Compressor? {
    let params = args as! Dictionary<String, Any>

    let haveList = params.contains { key, value in
      key == "list"
    }

    if (haveList) {
      let data = params["list"] as! FlutterStandardTypedData
      let nsData = data.data

      let image = getImageSrc(params: params) {
        CGImageSourceCreateWithData(nsData as CFData, nil)
      }

      guard let image = image else {
        result(makeFlutterError())
        return nil
      }

      return Compressor(image: image, params: params)
    }

    let havePath = params.contains { key, value in
      key == "path"
    }

    if (havePath) {
      let path = params["path"] as! String
      let image = getImageSrc(params: params) {
        let url = URL(fileURLWithPath: path)
        return CGImageSourceCreateWithURL(url as CFURL, nil)
      }

      guard let image = image else {
        result(makeFlutterError(code: "Incoming file can't be converted to image."))
        return nil
      }

      return Compressor(image: image, params: params)
    }

    result(makeFlutterError())

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

  let image: ImageSrc
  let params: Dictionary<String, Any>

  init(image: ImageSrc, params: Dictionary<String, Any>) {
    self.image = image
    self.params = params
  }

  func getOutputFormat() -> CFString {
    let format = params["format"] as! Int

    switch (format) {
    case 0:
      return kUTTypeJPEG
    case 1:
      return kUTTypePNG
    case 2:
      return AVFileType.heic as CFString
    default:
      return kUTTypeJPEG
    }
  }

  func compress(destCreator: () -> CGImageDestination) {
    let rotate = params["rotate"] as! Int
    let quality = params["quality"] as! Int

    let minWidth = params["minWidth"] as! Int
    let minHeight = params["minHeight"] as! Int

    let size = image.getSize()

    let srcWidth = size.width
    let srcHeight = size.height

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

//    let targetSize = NSMakeSize(targetWidth, targetHeight)
//    let targetRect = NSMakeRect(0, 0, targetWidth, targetHeight)

    let dest = destCreator()

    let options = [
      kCGImageDestinationLossyCompressionQuality: CGFloat(quality) / 100,
      kCGImageDestinationImageMaxPixelSize: max(targetWidth, targetHeight),
      kCGImageDestinationEmbedThumbnail: true
    ] as CFDictionary

    CGImageDestinationAddImageFromSource(dest, image.srcImage, 0, options)
    CGImageDestinationFinalize(dest)
  }

//  func compressData(_ resultHandler: @escaping (Any?) -> ()) -> Data? {
//    let data = NSMutableData()
//    compress {
//      CGImageDestinationCreateWithData(data, getOutputFormat(), 1, nil)!
//    }
//
////    let quality = params["quality"] as! Int
////    let format = params["format"] as! Int
////    let keepExif = params["keepExif"] as! Bool
////    let inSampleSize = params["inSampleSize"] as! Int
////    let autoCorrectionAngle = params["autoCorrectionAngle"] as! Bool
//
//    resultHandler(data)
//  }

  func compressToPath(_ result: @escaping (Any?) -> (), _ path: String) {
    let url = URL(fileURLWithPath: path)
    compress {
      CGImageDestinationCreateWithURL(url as CFURL, getOutputFormat(), 1, nil)!
    }

    result(path)
  }

  func compressToBytes(_ result: @escaping (Any?) -> ()) {
    let data = NSMutableData()
    compress {
      CGImageDestinationCreateWithData(data, getOutputFormat(), 1, nil)!
    }

    result(FlutterStandardTypedData(bytes: data as Data))
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
