@JS()
library pica;

import 'dart:html';
import 'dart:typed_data';

import 'package:js/js.dart';

import 'window.dart';
import 'log.dart' as logger;

@JS('pica().resize')
external dynamic resize(
  ImageBitmap imageBitmap,
  CanvasElement canvas,
);

Future<Uint8List> resizeWithList(
  Uint8List buffer,
  int width,
  int height,
) async {
  final bitmap = await convertUint8ListToBitmap(buffer);
  logger.log('bitmap', bitmap);
  final canvas = CanvasElement(width: width, height: height);
  logger.log('canvas', canvas);
  logger.log('resize', resize);
  await (resize(bitmap, canvas).toFuture());
  final blob = canvas.toDataUrl();

  logger.log('blob', blob);

  return buffer;
}
