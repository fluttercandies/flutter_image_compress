import 'dart:async';
import 'dart:js';
import 'dart:typed_data' as typed_data;
// import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
// import 'package:js/js.dart';

class FlutterImageCompressWeb extends FlutterImageCompressPlatform {
  static Future<void> changePicaUrl(String? url) async {
    // picaUrl = url;
    // await _loadScript();
  }

  static Future<void> _loadScript() async {
    // var script = document.createElement('script');
    // script.onload = function() {
    //   // pica 库成功加载后执行此处的代码
    //   console.log(window.pica);
    // };
    // script.src = 'https://cdn.jsdelivr.net/npm/pica@9.0.1/dist/pica.min.js';
    // document.head.appendChild(script);

    // Use dart to add
    // final head = html.window.document.getElementsByTagName('head').first;
    // final scriptNode = html.ScriptElement();
    // scriptNode.src = 'https://cdn.jsdelivr.net/npm/pica@9.0.1/dist/pica.min.js';
    // scriptNode.onLoad.listen((event) {
    //   _log('pica loaded');
    //   _log(js.context['pica']);
    // });
    // head.append(scriptNode);

    final pica = context['pica'];
    print('pica: $pica');

    // final pica = JsObject(
    //   await context.callMethod(
    //     'import',
    //     [
    //       'https://cdn.jsdelivr.net/npm/pica@9.0.1/dist/pica.min.js',
    //     ],
    //   ),
    // );

    // print('pica: $pica');

    // final scriptElement = html.window.document.getElementById('pica_script');
    // if (scriptElement != null) {
    //   scriptElement.remove();
    //   _log('remove old pica script');
    // }

    // final parent = html.window.document.getElementsByTagName('body').first;
    // final script = html.ScriptElement();
    // script.id = 'pica_script';
    // // Try load url from assets
    // if (picaUrl != null) {
    //   script.src = picaUrl!;
    //   _log('load pica url: ${script.src}');
    // }

    // script.onLoad.listen((event) {
    //   _log(js.context['pica']);
    // });

    // parent.append(script);
    // _log('add pica script to head');
    // _log('The new script:');
    // _log(script.outerHtml);

    // // const scriptContent = 'console.log("Hello script")';
    // // final script2 = html.ScriptElement();
    // // script2.async = true;
    // // script2.innerText = scriptContent;
    // // parent.append(script2);
  }

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

  void run() {}

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
    // final pica = require('pica')();
    // final pica = require('pica');

    final asset = await rootBundle.load(assetName);
    final buffer = asset.buffer.asUint8List();
    // use js pico to compress
    // print('pica:');

    run();

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
