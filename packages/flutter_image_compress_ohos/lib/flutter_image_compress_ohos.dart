// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';

class FlutterImageCompressOhos extends FlutterImageCompressPlatform {
  static const _channel = MethodChannel('flutter_image_compress');

  /// For flutter plugin registration.
  static void registerWith() {
    FlutterImageCompressPlatform.instance = FlutterImageCompressOhos();
  }

  Future<void> checkSupport(CompressFormat format) async {
    if (!(await validator.checkSupportPlatform(format))) {
      throw UnsupportedError('The image type $format is not supported.');
    }
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
    bool keepExif = true,
    int numberOfRetries = 5,
  }) async {
    await checkSupport(format);

    final dstPath = await _channel.invokeMethod('compressAndGetFile', {
      'path': path,
      'targetPath': targetPath,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'inSampleSize': inSampleSize,
      'quality': quality,
      'rotate': rotate,
      'autoCorrectionAngle': autoCorrectionAngle,
      'format': format.index,
      'keepExif': keepExif,
      'numberOfRetries': numberOfRetries,
    });

    if (dstPath == null) {
      return null;
    }

    return XFile(dstPath);
  }

  @override
  Future<Uint8List?> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = true,
    int numberOfRetries = 5,
  }) async {
    await checkSupport(format);

    final bytes = await rootBundle
        .load(assetName)
        .then((value) => value.buffer.asUint8List());

    return compressWithList(
      bytes,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
      format: format,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
  }

  @override
  Future<Uint8List?> compressWithFile(
    String path, {
    int minWidth = 1920,
    int minHeight = 1080,
    int inSampleSize = 1,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = true,
    int numberOfRetries = 5,
  }) async {
    await checkSupport(format);

    final result = await _channel.invokeMethod('compressWithFile', {
      'path': path,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'inSampleSize': inSampleSize,
      'quality': quality,
      'rotate': rotate,
      'autoCorrectionAngle': autoCorrectionAngle,
      'format': format.index,
      'keepExif': keepExif,
      'numberOfRetries': numberOfRetries,
    });

    if (result == null) {
      return null;
    }

    return result;
  }

  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = true,
    int numberOfRetries = 5,
  }) async {
    await checkSupport(format);

    final result = await _channel.invokeMethod<Uint8List>('compressWithList', {
      'list': image,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'inSampleSize': inSampleSize,
      'quality': quality,
      'rotate': rotate,
      'autoCorrectionAngle': autoCorrectionAngle,
      'format': format.index,
      'keepExif': keepExif,
      'numberOfRetries': numberOfRetries,
    });

    if (result == null) {
      throw Exception('Compress failed');
    }

    return result;
  }

  @override
  Future<void> showNativeLog(bool value) async {
    await _channel.invokeMethod('showLog', value);
  }

  @override
  FlutterImageCompressValidator get validator => _validator;
  final FlutterImageCompressValidator _validator =
      OhosFlutterImageCompressValidator(_channel);

  @override
  // ignore: avoid_renaming_method_parameters
  void ignoreCheckSupportPlatform(bool value) {
    _validator.ignoreCheckSupportPlatform = value;
  }
}

class OhosFlutterImageCompressValidator extends FlutterImageCompressValidator {
  OhosFlutterImageCompressValidator(MethodChannel channel) : super(channel);

  @override
  Future<bool> checkSupportPlatform(CompressFormat format) async {
    if (ignoreCheckSupportPlatform) {
      return true;
    }

    if (format == CompressFormat.heic) {
      return false;
    }

    return true;
  }
}
