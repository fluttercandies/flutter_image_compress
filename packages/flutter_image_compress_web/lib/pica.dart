@JS()
library pica;

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'window.dart';
import 'log.dart' as logger;

@JS('pica.resize')
external dynamic resize(
  ImageBitmap imageBitmap,
  CanvasElement canvas,
);

@JS()
@staticInterop
class Pica {}

extension PicaExt on Pica {
  external dynamic resize(
    ImageBitmap imageBitmap,
    CanvasElement canvas,
  );

  external dynamic init();
}

Future<Uint8List> resizeWithList(
  Uint8List buffer,
  int width,
  int height,
) async {
  final bitmap = await convertUint8ListToBitmap(buffer);
  logger.log('bitmap', bitmap);
  final canvas = CanvasElement(width: width, height: height);
  logger.log('canvas', canvas);

  final pica = jsWindow.pica() as Pica;
  logger.log('pica', pica);
  logger.log('pica.init', pica.init());
  // logger.log('pica.resize', pica.resize);

  final dynamic result = pica.resize(bitmap, canvas);
  await promiseToFuture(result);
  final blob = canvas.toDataUrl();
  final str = blob.split(',')[1];
  return base64Decode(str);
}
