import 'dart:async';
import 'dart:typed_data' as typed_data;

import 'package:flutter/services.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
export 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';

/// Image Compress plugin.
///
/// Method in the static class will help you to compress images,
/// most methods will return [Uint8List].
///
/// You can use `Image.memory` to display image:
/// ```dart
/// Uint8List uint8List;
/// ImageProvider provider = MemoryImage(uint8List);
/// ```
///
/// or
///
/// ```dart
/// Uint8List uint8List;
/// Image.memory(uint8List)
/// ```
///
/// The returned image will retain the proportion of the original image.
/// Compress image will remove its EXIF info. and the result is in jpeg format.
/// Rotation is also supported.
class FlutterImageCompress {
  static FlutterImageCompressPlatform get _platform =>
      FlutterImageCompressPlatform.instance;

  static FlutterImageCompressValidator get validator => _platform.validator;

  static set showNativeLog(bool value) {
    _platform.showNativeLog(value);
  }

  /// Compress image from [Uint8List] to [Uint8List].
  static Future<typed_data.Uint8List> compressWithList(
    typed_data.Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    return _platform.compressWithList(
      image,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
      inSampleSize: inSampleSize,
      autoCorrectionAngle: autoCorrectionAngle,
      format: format,
      keepExif: keepExif,
    );
  }

  /// Compress file of [path] to [Uint8List].
  static Future<typed_data.Uint8List?> compressWithFile(
    String path, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    return _platform.compressWithFile(
      path,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
      inSampleSize: inSampleSize,
      autoCorrectionAngle: autoCorrectionAngle,
      format: format,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
  }

  /// From [path] to [targetPath]
  static Future<XFile?> compressAndGetFile(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    return _platform.compressAndGetFile(
      path,
      targetPath,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
      inSampleSize: inSampleSize,
      autoCorrectionAngle: autoCorrectionAngle,
      format: format,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
  }

  /// From [asset] to [Uint8List]
  static Future<typed_data.Uint8List?> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    return _platform.compressAssetImage(
      assetName,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
      format: format,
      keepExif: keepExif,
    );
  }

  static void ignoreCheckSupportPlatform(bool value) {
    _platform.ignoreCheckSupportPlatform(value);
  }
}
