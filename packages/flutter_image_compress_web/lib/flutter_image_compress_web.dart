import 'dart:typed_data' as typed_data;
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Future<void> _loadScript() async {
  final head = html.window.document.getElementsByTagName('head').first;
  final script = html.ScriptElement()..type = 'text/javascript';
  // Try load url from assets
  try {
    final url = await rootBundle.loadString('pica_url');
    script.src = url;
    // print('pica url: $url');
    _log('load pica url: $url');
  } catch (e) {
    // print('The e: $e');
    final picaScript = await rootBundle
        .loadString('packages/flutter_image_compress_web/assets/pica.min.js');
    script.innerHtml = picaScript;
    _log('load asset pica.min.js');
  }

  head.append(script);
}

class FlutterImageCompressWeb extends FlutterImageCompressPlatform {
  static void registerWith(Registrar registrar) {
    WidgetsFlutterBinding.ensureInitialized();
    _loadScript().then(
      (value) {
        FlutterImageCompressPlatform.instance = FlutterImageCompressWeb();
      },
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
    throw UnimplementedError();
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
    // pico
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

void _log(String message) {
  if (_showLog) {
    // ignore: avoid_print
    print(message);
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
