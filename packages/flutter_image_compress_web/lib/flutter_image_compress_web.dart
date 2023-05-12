import 'dart:async';
import 'dart:typed_data' as typed_data;

import 'package:flutter/services.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_image_compress_web/src/log.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/pica.dart';

class FlutterImageCompressWeb extends FlutterImageCompressPlatform {
  static void registerWith(Registrar registrar) {
    FlutterImageCompressPlatform.instance = FlutterImageCompressWeb();
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
  }) {
    throw UnimplementedError('The method not support web');
  }

  @override
  Future<typed_data.Uint8List?> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    final asset = await rootBundle.load(assetName);
    final buffer = asset.buffer.asUint8List();
    return resizeWithList(
      buffer: buffer,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      format: format,
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
  }) {
    throw UnimplementedError('The method not support web');
  }

  @override
  Future<typed_data.Uint8List> compressWithList(
    typed_data.Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) {
    return resizeWithList(
      buffer: image,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      format: format,
    );
  }

  @override
  void ignoreCheckSupportPlatform(bool bool) {}

  @override
  Future<void> showNativeLog(bool value) async {
    showLog = value;
  }

  @override
  FlutterImageCompressValidator get validator =>
      _FlutterImageCompressValidator();
}

class _FlutterImageCompressValidator extends FlutterImageCompressValidator {
  _FlutterImageCompressValidator()
      : super(
          const MethodChannel('flutter_image_compress'),
        );

  @override
  void checkFileNameAndFormat(String name, CompressFormat format) {}
  @override
  Future<bool> checkSupportPlatform(CompressFormat format) async {
    return true;
  }
}
