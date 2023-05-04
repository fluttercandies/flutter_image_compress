// ignore_for_file: require_trailing_commas

import 'dart:async';
import 'dart:io';
import 'dart:typed_data' as typed_data;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';

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
class FlutterImageCompressCommon extends FlutterImageCompressPlatform {
  static const _channel = MethodChannel('flutter_image_compress');

  @override
  FlutterImageCompressValidator get validator => _validator;
  final FlutterImageCompressValidator _validator =
      FlutterImageCompressValidator(_channel);

  /// For flutter plugin registration.
  static void registerWith() {
    FlutterImageCompressPlatform.instance = FlutterImageCompressCommon();
  }

  @override
  Future<typed_data.Uint8List?> compressAssetImage(String assetName,
      {int minWidth = 1920,
      int minHeight = 1080,
      int quality = 95,
      int rotate = 0,
      bool autoCorrectionAngle = true,
      CompressFormat format = CompressFormat.jpeg,
      bool keepExif = false}) async {
    final support = await _validator.checkSupportPlatform(format);
    if (!support) {
      return null;
    }
    final img = AssetImage(assetName);
    const config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final uint8List = data.buffer.asUint8List();
    if (uint8List.isEmpty) {
      return null;
    }
    return compressWithList(
      uint8List,
      minHeight: minHeight,
      minWidth: minWidth,
      quality: quality,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
      format: format,
      keepExif: keepExif,
    );
  }

  @override
  Future<typed_data.Uint8List?> compressWithFile(
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
    if (numberOfRetries <= 0) {
      throw CompressError("numberOfRetries can't be null or less than 0");
    }
    if (!File(path).existsSync()) {
      throw CompressError('Image file does not exist in $path.');
    }
    final support = await _validator.checkSupportPlatform(format);
    if (!support) {
      return null;
    }
    final result = await _channel.invokeMethod('compressWithFile', [
      path,
      minWidth,
      minHeight,
      quality,
      rotate,
      autoCorrectionAngle,
      _convertTypeToInt(format),
      keepExif,
      inSampleSize,
      numberOfRetries
    ]);
    return result;
  }

  @override
  Future<typed_data.Uint8List> compressWithList(typed_data.Uint8List image,
      {int minWidth = 1920,
      int minHeight = 1080,
      int quality = 95,
      int rotate = 0,
      int inSampleSize = 1,
      bool autoCorrectionAngle = true,
      CompressFormat format = CompressFormat.jpeg,
      bool keepExif = false}) async {
    if (image.isEmpty) {
      throw CompressError('The image is empty.');
    }
    final support = await _validator.checkSupportPlatform(format);
    if (!support) {
      throw UnsupportedError('The image type $format is not supported.');
    }
    final result = await _channel.invokeMethod('compressWithList', [
      image,
      minWidth,
      minHeight,
      quality,
      rotate,
      autoCorrectionAngle,
      _convertTypeToInt(format),
      keepExif,
      inSampleSize,
    ]);
    return result;
  }

  @override
  Future<void> showNativeLog(bool value) async {
    await _channel.invokeMethod('showLog', value);
  }

  @override
  Future<XFile?> compressAndGetFile(
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
    if (numberOfRetries <= 0) {
      throw CompressError("numberOfRetries can't be null or less than 0");
    }
    if (!File(path).existsSync()) {
      throw CompressError('Image file does not exist in $path.');
    }
    if (path == targetPath) {
      throw CompressError('Target path and source path cannot be the same.');
    }
    _validator.checkFileNameAndFormat(targetPath, format);
    final support = await _validator.checkSupportPlatform(format);
    if (!support) {
      return null;
    }
    final String? result = await _channel.invokeMethod(
      'compressWithFileAndGetFile',
      [
        path,
        minWidth,
        minHeight,
        quality,
        targetPath,
        rotate,
        autoCorrectionAngle,
        _convertTypeToInt(format),
        keepExif,
        inSampleSize,
        numberOfRetries,
      ],
    );
    if (result == null) {
      return null;
    }
    return XFile(result);
  }

  @override
  void ignoreCheckSupportPlatform(bool value) {
    _validator.ignoreCheckSupportPlatform = value;
  }
}

int _convertTypeToInt(CompressFormat format) => format.index;
