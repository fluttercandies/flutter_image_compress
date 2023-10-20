import Cocoa
import FlutterMacOS
import AVFoundation

class Logger {

  static var isShowLog = false

  static func showLog(show: Bool) {
    isShowLog = show
  }

  static func log(msg: String) {
    if (!isShowLog) {
      return
    }
    NSLog("\(msg)")
  }

  static func logFile(path: String) {
    if (!isShowLog) {
      return
    }
    let url = URL(fileURLWithPath: path)
    NSLog("The file: \(url)")
  }

  static func logData(data: Data) {
    if (!isShowLog) {
      return
    }
    NSLog("The data: \(data), length: \(data.count)")

    // check data type, maybe jpeg png or heic
    let isJpeg = data[0] == 0xFF && data[1] == 0xD8
    let isPng = data[0] == 0x89 && data[1] == 0x50

    let heicHeader = "ftypheic"
    let isHeic = data.count > heicHeader.count && String(data: data.subdata(in: 4..<heicHeader.count + 4), encoding: .utf8) == heicHeader

    let outputFormat = isJpeg ? "jpg" : (isPng ? "png" : (isHeic ? "heic" : "unknown"))

    // write data to file
    let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(Date().timeIntervalSince1970).\(outputFormat)")
    do {
      try data.write(to: url)
      NSLog("The file: \(url)")
    } catch {
      NSLog("Write file error: \(error)")
    }
  }
}

class ImageSrc {
  let image: NSImage
  let params: Dictionary<String, Any>

  init(image: NSImage, params: Dictionary<String, Any>) {
    self.image = image
    self.params = params
  }

}

public class FlutterImageCompressMacosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_image_compress", binaryMessenger: registrar.messenger)
    let instance = FlutterImageCompressMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func injectDict(_ imageProperties: NSDictionary, _ dest: NSMutableDictionary, _ key: CFString) {
    let dict = imageProperties[key]
    if (dict != nil) {
      let properties = dict as! NSDictionary
      for (key, value) in properties {
        dest[key] = value
      }
    }
  }

  func makeImageSrc(image: NSImage, source: CGImageSource, params: Dictionary<String, Any>) -> ImageSrc {
    let keepExif = params["keepExif"] as! Bool

    let exifDict = NSMutableDictionary()
    if (keepExif) {
      let imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)! as NSDictionary

      injectDict(imageProperties, exifDict, kCGImagePropertyExifDictionary)
      injectDict(imageProperties, exifDict, kCGImagePropertyJFIFDictionary)
      injectDict(imageProperties, exifDict, kCGImagePropertyTIFFDictionary)
      injectDict(imageProperties, exifDict, kCGImagePropertyPNGDictionary)
    }

    return ImageSrc(image: image, params: exifDict as! Dictionary<String, Any>)
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

      guard let nsImage = NSImage(data: nsData),
            let source = CGImageSourceCreateWithData(nsData as CFData, nil)
      else {
        result(makeFlutterError())
        return nil
      }
      let image = makeImageSrc(image: nsImage, source: source, params: params)
      return Compressor(image: image, params: params)
    }

    let havePath = params.contains { key, value in
      key == "path"
    }

    if (havePath) {
      let path = params["path"] as! String
      guard let nsImage = NSImage(contentsOfFile: path),
            let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil)
      else {
        result(makeFlutterError())
        return nil
      }

      let image = makeImageSrc(image: nsImage, source: source, params: params)
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


  /**
   处理图片
   - Parameters:
     - image: 源图片
     - angle: 角度
     - targetSize: 目标图片的尺寸
     - dest: 目标图片
   */
  func handleImage(image: NSImage, angle: Int, targetSize: CGSize, dest: CGImageDestination) {
    // 先处理一次图片到 targetSize 的尺寸
    let srcCGContext = CGContext(data: nil, width: Int(targetSize.width), height: Int(targetSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    srcCGContext.draw(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
    let srcCGImage = srcCGContext.makeImage()!

    print("srcCGImage: \(srcCGImage.width) x \(srcCGImage.height)")

    // 由于 angle 是 Int 类型，所以需要转换成弧度
    let radian = CGFloat(angle) * CGFloat.pi / 180

    // 旋转图片，这里的旋转是以图片中心点为中心旋转，并且要考虑到图片的尺寸可能会有变化，因为可能不是90的倍数
    let affine = CGAffineTransform(rotationAngle: radian)
    let width = srcCGImage.width
    let height = srcCGImage.height

    let srcRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
    let newRect = srcRect.applying(affine)

    let rotatedSize = CGSize(width: newRect.width, height: newRect.height)

    // 获取一个旋转后的图片
    let cgContext = CGContext(data: nil, width: Int(rotatedSize.width), height: Int(rotatedSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

    cgContext.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    cgContext.rotate(by: radian)

    cgContext.draw(srcCGImage, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))

    let rotatedImage = cgContext.makeImage()!

    // 将旋转后的图片写入到目标图片中
    let options = makeOptions()

    CGImageDestinationAddImage(dest, rotatedImage, options)
//  CGImageDestinationAddImage(dest, srcCGImage, options)

    CGImageDestinationFinalize(dest)
  }

  private func makeOptions() -> CFDictionary {
    let dict = NSMutableDictionary()

    let quality = params["quality"] as! Int
    let qualityValue = CGFloat(quality) / 100.0

    let keepExif = params["keepExif"] as! Bool

    if (keepExif) {
      // remove orientation
      dict[kCGImagePropertyOrientation] = 1

      for param in image.params {
        if kCGImagePropertyOrientation as String == param.key {
          continue
        }
        dict[param.key] = param.value
      }
    }

    dict[kCGImageDestinationLossyCompressionQuality] = qualityValue

    return dict as CFDictionary
  }

  func compress(destCreator: () -> CGImageDestination) {
    let minWidth = CGFloat(params["minWidth"] as! Int)
    let minHeight = CGFloat(params["minHeight"] as! Int)

    let srcWidth = image.image.size.width
    let srcHeight = image.image.size.height

    let srcRatio = srcWidth / srcHeight
    let maxRatio = minWidth / minHeight
    var scaleRatio = 1.0

    if srcRatio < maxRatio {
      scaleRatio = minWidth / srcWidth
    } else {
      scaleRatio = minHeight / srcHeight
    }

    scaleRatio = min(scaleRatio, 1.0)

    let targetWidth = srcWidth * scaleRatio
    let targetHeight = srcHeight * scaleRatio

    let targetSize = CGSize(width: targetWidth, height: targetHeight)
    let dest = destCreator()
    let angle = params["rotate"] as! Int

    handleImage(image: image.image, angle: angle, targetSize: targetSize, dest: dest)
  }

  func compressToPath(_ result: @escaping (Any?) -> (), _ path: String) {
    let url = URL(fileURLWithPath: path)
    compress {
      CGImageDestinationCreateWithURL(url as CFURL, getOutputFormat(), 1, nil)!
    }

    Logger.logFile(path: path)
    result(path)
  }

  func compressToBytes(_ result: @escaping (Any?) -> ()) {
    let data = NSMutableData()
    compress {
      CGImageDestinationCreateWithData(data, getOutputFormat(), 1, nil)!
    }

    Logger.logData(data: data as Data)
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
