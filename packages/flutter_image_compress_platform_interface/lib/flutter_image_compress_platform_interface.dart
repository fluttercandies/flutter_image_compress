import 'dart:typed_data' as typed_data;

import 'package:cross_file/cross_file.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/compress_format.dart';
import 'src/validator.dart';

export 'package:cross_file/cross_file.dart';
export 'src/compress_format.dart';
export 'src/errors.dart';
export 'src/validator.dart';

const _kUnsupportedHint = '\n\nCommon causes:\n'
    '  * Calling from a background Isolate - either move to the main '
    'isolate, or call BackgroundIsolateBinaryMessenger.ensureInitialized(...) '
    'inside the isolate before use.\n'
    '  * No implementation registered for the current platform (Windows is '
    'not supported; for Linux, add package:flutter_image_compress_linux).\n'
    '  * Release/minified web build where platform detection fails - try '
    'flutter build web --profile to confirm.';

abstract class FlutterImageCompressPlatform extends PlatformInterface {
  FlutterImageCompressPlatform() : super(token: _token);

  static const _token = Object();

  static FlutterImageCompressPlatform instance =
      UnsupportedFlutterImageCompress();

  FlutterImageCompressValidator get validator;

  Future<void> showNativeLog(bool value);

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
  });

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
  });

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
  });

  Future<typed_data.Uint8List?> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  });

  void ignoreCheckSupportPlatform(bool bool);
}

class UnsupportedFlutterImageCompress extends FlutterImageCompressPlatform {
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
  }) {
    throw UnimplementedError(
      'FlutterImageCompress.compressAssetImage is not available.'
      '$_kUnsupportedHint',
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
    throw UnimplementedError(
      'FlutterImageCompress.compressWithFile is not available.'
      '$_kUnsupportedHint',
    );
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
    throw UnimplementedError(
      'FlutterImageCompress.compressAndGetFile is not available.'
      '$_kUnsupportedHint',
    );
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
    throw UnimplementedError(
      'FlutterImageCompress.compressWithList is not available.'
      '$_kUnsupportedHint',
    );
  }

  @override
  Future<void> showNativeLog(bool value) {
    throw UnimplementedError(
      'FlutterImageCompress.showNativeLog is not available.'
      '$_kUnsupportedHint',
    );
  }

  @override
  void ignoreCheckSupportPlatform(bool bool) {
    throw UnimplementedError(
      'FlutterImageCompress.ignoreCheckSupportPlatform is not available.'
      '$_kUnsupportedHint',
    );
  }

  @override
  FlutterImageCompressValidator get validator => throw UnimplementedError(
        'FlutterImageCompress.validator is not available.'
        '$_kUnsupportedHint',
      );
}
