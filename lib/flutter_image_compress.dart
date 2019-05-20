import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

/// Image Compress
///
/// static method will help you compress image
///
/// most method will return [List<int>]
///
/// convert List<int> to [Uint8List] and use [Image.memory(uint8List)] to display image
/// ```dart
/// var u8 = Uint8List.fromList(list)
/// ImageProvider provider = MemoryImage(Uint8List.fromList(list));
/// ```
///
/// The returned image will retain the proportion of the original image.
///
/// Compress image will remove EXIF.
///
/// image result is jpeg format.
///
/// support rotate
///
class FlutterImageCompress {
  static const MethodChannel _channel =
      const MethodChannel('flutter_image_compress');

  static set showNativeLog(bool value) {
    _channel.invokeMethod("showLog", value);
  }

  /// Compress image from [List<int>] to [List<int>]
  static Future<List<int>> compressWithList(
    List<int> image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
  }) async {
    assert(
      image != null,
      "A non-null List<int> must be provided to FlutterImageCompress.",
    );
    if (image == null) {
      return [];
    }
    if (image.isEmpty) {
      return [];
    }
    final result = await _channel.invokeMethod("compressWithList", [
      Uint8List.fromList(image),
      minWidth,
      minHeight,
      quality,
      rotate,
      autoCorrectionAngle,
    ]);

    return convertDynamic(result);
  }

  /// Compress file of [path] to [List<int>].
  static Future<List<int>> compressWithFile(
    String path, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
  }) async {
    assert(
      path != null,
      "A non-null String must be provided to FlutterImageCompress.",
    );
    if (path == null || !File(path).existsSync()) {
      return [];
    }
    final result = await _channel.invokeMethod("compressWithFile", [
      path,
      minWidth,
      minHeight,
      quality,
      rotate,
      autoCorrectionAngle,
    ]);
    return convertDynamic(result);
  }

  /// From [path] to [targetPath]
  static Future<File> compressAndGetFile(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
  }) async {
    assert(
      path != null,
      "A non-null String must be provided to FlutterImageCompress.",
    );
    if (path == null || !File(path).existsSync()) {
      return null;
    }

    final String result =
        await _channel.invokeMethod("compressWithFileAndGetFile", [
      path,
      minWidth,
      minHeight,
      quality,
      targetPath,
      rotate,
      autoCorrectionAngle,
    ]);

    if (result == null) {
      return null;
    }

    return File(result);
  }

  /// From [asset] to [List<int>]
  static Future<List<int>> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
  }) async {
    assert(
      assetName != null,
      "A non-null String must be provided to FlutterImageCompress.",
    );
    if (assetName == null) {
      return [];
    }

    var img = AssetImage(assetName);
    var config = ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);

    var uint8List = data.buffer.asUint8List();

    if (uint8List == null || uint8List.isEmpty) {
      return [];
    }

    return compressWithList(
      uint8List,
      minHeight: minHeight,
      minWidth: minWidth,
      quality: quality,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
    );
  }

  /// convert [List<dynamic>] to [List<int>]
  static List<int> convertDynamic(List<dynamic> list) {
    if (list == null || list.isEmpty) {
      return [];
    }

    return list
        .where((item) => item is int)
        .map((item) => item as int)
        .toList();
  }
}

/// get [ImageInfo] from [ImageProvider]
Future<ImageInfo> getImageInfo(BuildContext context, ImageProvider provider,
    {Size size}) async {
  final ImageConfiguration config =
      createLocalImageConfiguration(context, size: size);
  final Completer<ImageInfo> completer = Completer<ImageInfo>();
  final ImageStream stream = provider.resolve(config);
  void listener(ImageInfo image, bool sync) {
    completer.complete(image);
  }

  void errorListener(dynamic exception, StackTrace stackTrace) {
    completer.complete(null);
    FlutterError.reportError(FlutterErrorDetails(
      context: 'image load failed ',
      library: 'flutter_image_compress',
      exception: exception,
      stack: stackTrace,
      silent: true,
    ));
  }

  stream.addListener(listener, onError: errorListener);
  completer.future.then((ImageInfo info) {
    stream.removeListener(listener);
  });
  return completer.future;
}
