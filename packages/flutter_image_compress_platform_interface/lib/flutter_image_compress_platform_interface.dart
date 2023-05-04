import 'package:cross_file/cross_file.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:typed_data' as typed_data;

import 'src/compress_format.dart';
import 'src/validator.dart';

export 'src/compress_format.dart';
export 'src/errors.dart';
export 'src/validator.dart';
export 'package:cross_file/cross_file.dart';

abstract class FlutterImageCompressPlatform extends PlatformInterface {
  static const _token = Object();

  static FlutterImageCompressPlatform instance =
      UnsupportedFlutterImageCompress();

  FlutterImageCompressPlatform() : super(token: _token);

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
  Future<typed_data.Uint8List?> compressAssetImage(String assetName,
      {int minWidth = 1920,
      int minHeight = 1080,
      int quality = 95,
      int rotate = 0,
      bool autoCorrectionAngle = true,
      CompressFormat format = CompressFormat.jpeg,
      bool keepExif = false}) {
    throw UnimplementedError();
  }

  @override
  Future<typed_data.Uint8List?> compressWithFile(String path,
      {int minWidth = 1920,
      int minHeight = 1080,
      int inSampleSize = 1,
      int quality = 95,
      int rotate = 0,
      bool autoCorrectionAngle = true,
      CompressFormat format = CompressFormat.jpeg,
      bool keepExif = false,
      int numberOfRetries = 5}) {
    throw UnimplementedError();
  }

  @override
  Future<XFile?> compressAndGetFile(String path, String targetPath,
      {int minWidth = 1920,
      int minHeight = 1080,
      int inSampleSize = 1,
      int quality = 95,
      int rotate = 0,
      bool autoCorrectionAngle = true,
      CompressFormat format = CompressFormat.jpeg,
      bool keepExif = false,
      int numberOfRetries = 5}) {
    throw UnimplementedError();
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
      bool keepExif = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> showNativeLog(bool value) {
    throw UnimplementedError();
  }

  @override
  void ignoreCheckSupportPlatform(bool bool) {
    throw UnimplementedError();
  }

  @override
  FlutterImageCompressValidator get validator => throw UnimplementedError();
}
