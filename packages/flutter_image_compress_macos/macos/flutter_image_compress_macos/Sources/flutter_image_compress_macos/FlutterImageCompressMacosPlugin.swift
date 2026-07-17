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
  // Full CGImageSource property dictionary from the source, preserved with
  // its nested sub-dicts (EXIF, TIFF, GPS, IPTC, PNG). Empty when the
  // caller did not request keepExif. Consumers must NOT flatten the
  // sub-dicts into top-level options: CGImageDestination requires them
  // under their container keys (kCGImagePropertyExifDictionary, etc.), so
  // the flattened-shape variant this used to write silently produced JPEGs
  // with no source metadata.
  let sourceProperties: [CFString: Any]

  init(image: NSImage, sourceProperties: [CFString: Any]) {
    self.image = image
    self.sourceProperties = sourceProperties
  }

}

public class FlutterImageCompressMacosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_image_compress", binaryMessenger: registrar.messenger)
    let instance = FlutterImageCompressMacosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func makeImageSrc(image: NSImage, source: CGImageSource, params: Dictionary<String, Any>) -> ImageSrc {
    let keepExif = params["keepExif"] as! Bool

    guard keepExif,
          let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    else {
      return ImageSrc(image: image, sourceProperties: [:])
    }
    return ImageSrc(image: image, sourceProperties: props)
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

    // showLog is a fast setter — reply on the calling thread and skip the
    // background hop. Every branch of handle(...) must resolve `result`,
    // otherwise the awaiting Dart future hangs forever.
    if method == "showLog" {
      Logger.showLog(show: args as! Bool)
      result(1)
      return
    }

    // Compression (decode / CGContext resize+rotate / CGImageDestination
    // encode / disk write) is CPU- and I/O-heavy. FlutterMethodChannel
    // dispatches on the AppKit main thread, so running the work inline
    // stalls Flutter's UI. Offload to a background queue and marshal the
    // FlutterResult back to the platform thread — same pattern as the
    // Android threadPool + main-Looper Handler and iOS global-queue
    // handlers.
    let mainResult: FlutterResult = { value in
      if Thread.isMainThread {
        result(value)
      } else {
        DispatchQueue.main.async { result(value) }
      }
    }

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else {
        // Plugin was detached before we got scheduled. Reply anyway so the
        // Dart future doesn't hang; the engine tolerates result(...) on a
        // torn-down channel.
        mainResult(FlutterError(code: "plugin_detached",
                                message: "Plugin was detached before compression could start",
                                details: nil))
        return
      }
      switch method {
      case "compressAndGetFile":
        let dstPath = (args as! Dictionary<String, Any>)["targetPath"] as! String
        self.handleResult(args, mainResult)?.compressToPath(mainResult, dstPath)
      case "compressWithFile":
        self.handleResult(args, mainResult)?.compressToBytes(mainResult)
      case "compressWithList":
        self.handleResult(args, mainResult)?.compressToBytes(mainResult)
      default:
        mainResult(FlutterMethodNotImplemented)
      }
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
  func handleImage(image: NSImage, angle: Int, targetSize: CGSize, dest: CGImageDestination) -> Bool {
    // 先处理一次图片到 targetSize 的尺寸
    guard let srcCGContext = CGContext(
      data: nil,
      width: Int(targetSize.width),
      height: Int(targetSize.height),
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      Logger.log(msg: "CGContext creation failed for targetSize \(targetSize) — bitmap params may be invalid")
      return false
    }
    guard let sourceCGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      Logger.log(msg: "NSImage has no CGImage representation — cannot compress")
      return false
    }
    srcCGContext.draw(sourceCGImage, in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
    guard let srcCGImage = srcCGContext.makeImage() else {
      Logger.log(msg: "srcCGContext.makeImage() returned nil — could not snapshot resized source")
      return false
    }

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
    guard let cgContext = CGContext(
      data: nil,
      width: Int(rotatedSize.width),
      height: Int(rotatedSize.height),
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      Logger.log(msg: "CGContext creation failed for rotatedSize \(rotatedSize) — bitmap params may be invalid")
      return false
    }

    cgContext.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    cgContext.rotate(by: radian)

    cgContext.draw(srcCGImage, in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))

    guard let rotatedImage = cgContext.makeImage() else {
      Logger.log(msg: "cgContext.makeImage() returned nil — could not snapshot rotated image")
      return false
    }

    // 将旋转后的图片写入到目标图片中
    let options = makeOptions()

    CGImageDestinationAddImage(dest, rotatedImage, options)
//  CGImageDestinationAddImage(dest, srcCGImage, options)

    // Check finalize's return — with metadata-rich options (keepExif=true),
    // HEIC especially can silently reject a source-shape sub-dict and
    // write nothing, in which case handleImage should report failure so
    // the caller returns nil rather than a zero-byte file.
    if !CGImageDestinationFinalize(dest) {
      Logger.log(msg: "CGImageDestinationFinalize returned false — destination refused the image or options dict")
      return false
    }
    return true
  }

  private func makeOptions() -> CFDictionary {
    let dict = NSMutableDictionary()

    let quality = params["quality"] as! Int
    let qualityValue = CGFloat(quality) / 100.0

    let keepExif = params["keepExif"] as! Bool

    if keepExif {
      // Copy the source property dictionary through with its nested
      // sub-dicts intact. CGImageDestination reads sub-dicts (EXIF, TIFF,
      // GPS, IPTC, PNG) only when they appear under their container keys
      // — flattening them silently drops the data. Then sanitize the
      // fields that describe the *source* pixel buffer / dimensions,
      // which no longer describe the re-encoded output:
      //  - PixelWidth/PixelHeight/FileSize removed (destination writes them)
      //  - Orientation forced to 1 (rotation is baked into pixels by
      //    handleImage: below)
      //  - ProfileName/ColorModel/Depth/HasAlpha/IsFloat/IsIndexed removed
      //    (a Display-P3 ProfileName lying on an sRGB JPEG output makes
      //    color-managed viewers render wrong colors; HasAlpha=YES from
      //    a transparent PNG source on a JPEG output writes contradictory
      //    metadata)
      let source = image.sourceProperties
      let staleTopLevel: Set<CFString> = [
        kCGImagePropertyPixelWidth,
        kCGImagePropertyPixelHeight,
        kCGImagePropertyFileSize,
        kCGImagePropertyProfileName,
        kCGImagePropertyColorModel,
        kCGImagePropertyDepth,
        kCGImagePropertyHasAlpha,
        kCGImagePropertyIsFloat,
        kCGImagePropertyIsIndexed,
      ]
      for (key, value) in source {
        if key == kCGImagePropertyOrientation { continue }
        if staleTopLevel.contains(key) { continue }
        dict[key] = value
      }
      dict[kCGImagePropertyOrientation] = 1

      // Overwrite TIFF-side orientation and drop EXIF-side pixel dimension
      // hints so the sub-dicts don't contradict the reset top-level
      // orientation or the encoder's real dimensions.
      if let tiff = source[kCGImagePropertyTIFFDictionary] as? [CFString: Any] {
        var updated = tiff
        updated[kCGImagePropertyTIFFOrientation] = 1
        dict[kCGImagePropertyTIFFDictionary] = updated
      }
      if let exif = source[kCGImagePropertyExifDictionary] as? [CFString: Any] {
        var updated = exif
        updated.removeValue(forKey: kCGImagePropertyExifPixelXDimension)
        updated.removeValue(forKey: kCGImagePropertyExifPixelYDimension)
        dict[kCGImagePropertyExifDictionary] = updated
      }
    }

    dict[kCGImageDestinationLossyCompressionQuality] = qualityValue

    return dict as CFDictionary
  }

  func compress(destCreator: () -> CGImageDestination?) -> Bool {
    let minWidth = CGFloat(params["minWidth"] as! Int)
    let minHeight = CGFloat(params["minHeight"] as! Int)
    
    // NSImage sometimes returns wrong image size. See https://stackoverflow.com/a/9265331/3966361

    // NSImage size method returns size information that is screen resolution dependent.
    // let srcWidth = image.image.size.width
    // let srcHeight = image.image.size.height

    // NSImageRep should be used to get the size represented in the actual file image instead. 
    var srcWidth:CGFloat = 0
    var srcHeight:CGFloat = 0
    
    for imageRep in image.image.representations {
        let width = CGFloat(imageRep.pixelsWide)
        let height = CGFloat(imageRep.pixelsHigh)

        if width > srcWidth {
            srcWidth = width
        }
        
        if height > srcHeight {
            srcHeight = height
        }
    }

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
    guard let dest = destCreator() else {
      return false
    }
    let angle = params["rotate"] as! Int

    if !handleImage(image: image.image, angle: angle, targetSize: targetSize, dest: dest) {
      return false
    }
    return true
  }

  func compressToPath(_ result: @escaping (Any?) -> (), _ path: String) {
    let url = URL(fileURLWithPath: path)
    let ok = compress { () -> CGImageDestination? in
      guard let dest = CGImageDestinationCreateWithURL(url as CFURL, getOutputFormat(), 1, nil) else {
        Logger.log(msg: "CGImageDestinationCreateWithURL returned nil for path \(path) — format may be unsupported or path unwritable")
        return nil
      }
      return dest
    }

    if (!ok) {
      result(FlutterError(code: "encode_failed",
                          message: "Failed to encode compressed image to \(path)",
                          details: nil))
      return
    }

    Logger.logFile(path: path)
    result(path)
  }

  func compressToBytes(_ result: @escaping (Any?) -> ()) {
    let data = NSMutableData()
    let ok = compress { () -> CGImageDestination? in
      guard let dest = CGImageDestinationCreateWithData(data, getOutputFormat(), 1, nil) else {
        Logger.log(msg: "CGImageDestinationCreateWithData returned nil — output format may be unsupported on this macOS version")
        return nil
      }
      return dest
    }

    if (!ok) {
      result(FlutterError(code: "encode_failed",
                          message: "Failed to encode compressed image",
                          details: nil))
      return
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
