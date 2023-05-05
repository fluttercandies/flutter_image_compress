import 'dart:async';
import 'dart:html';
import 'dart:js' as js;
import 'dart:typed_data' as typed_data;
import 'dart:html' as html;
import 'dart:ui';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'pica.dart';
import 'window.dart';
import 'log.dart' as logger;
// import 'package:js/js.dart';

class FlutterImageCompressWeb extends FlutterImageCompressPlatform {
  static void registerWith(Registrar registrar) {
    WidgetsFlutterBinding.ensureInitialized();
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
    throw UnimplementedError();
  }

  Future<Uint8List> _resize(Uint8List buffer, int width, int height) async {
    return resizeWithList(buffer, width, height);
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

    print('prepare resize');

    // final result = await _resize(buffer, minWidth, minHeight);
    // print('result: $result');
    final bitmap = await _resize(buffer, 320, 480);
    logger.log('Hello', bitmap);

    return null;
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
    // TODO: implement compressWithFile
    throw UnimplementedError();
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
    // TODO: implement compressWithList
    throw UnimplementedError();
  }

  @override
  void ignoreCheckSupportPlatform(bool bool) {
    // TODO: implement ignoreCheckSupportPlatform
  }

  @override
  Future<void> showNativeLog(bool value) async {
    _showLog = true;
  }

  @override
  FlutterImageCompressValidator get validator => FlutterImageCompressValidator(
      const MethodChannel('flutter_image_compress'));
}

bool _showLog = true;

void _log(Object? message) {
  if (_showLog) {
    // ignore: avoid_print
    print(message?.toString());
  }
}

class _FlutterImageCompressValidator extends FlutterImageCompressValidator {
  _FlutterImageCompressValidator(super.channel);

  @override
  void checkFileNameAndFormat(String name, CompressFormat format) {}
  @override
  Future<bool> checkSupportPlatform(CompressFormat format) async {
    return true;
  }
}
