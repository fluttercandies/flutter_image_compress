library pica;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:web/web.dart';

import 'log.dart' as logger;
import 'util.dart';

Future<Uint8List> resizeWithList({
  required Uint8List buffer,
  required int minWidth,
  required int minHeight,
  CompressFormat format = CompressFormat.jpeg,
  int quality = 88,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final bitmap = await buffer.toImageBitmap();

  final srcWidth = bitmap.width;
  final srcHeight = bitmap.height;

  final ratio = srcWidth / srcHeight;

  final width = srcWidth > minWidth ? minWidth : srcWidth;
  final height = width ~/ ratio;

  logger.jsLog('src size', '$srcWidth x $srcHeight');
  logger.jsLog('target size', '$width x $height');

  final canvas = HTMLCanvasElement();
  canvas.width = width;
  canvas.height = height;

  final ctx = canvas.getContext('2d') as CanvasRenderingContext2D?;
  ctx?.clearRect(0, 0, width, height);
  ctx?.drawImage(bitmap, 0, 0, width, height);

  final blob = canvas.toDataUrl(format.type, quality / 100);
  final str = blob.split(',')[1];

  bitmap.close();
  final result = base64Decode(str);
  logger.dartLog('compressed image buffer length: ${result.length}');
  logger.dartLog('compressed took ${stopwatch.elapsedMilliseconds}ms');

  return result;
}

extension CompressExt on CompressFormat {
  String get type {
    switch (this) {
      case CompressFormat.jpeg:
        return 'image/jpeg';
      case CompressFormat.png:
        return 'image/png';
      case CompressFormat.webp:
        return 'image/webp';
      case CompressFormat.heic:
        throw UnimplementedError('heic is not support web');
    }
  }
}
