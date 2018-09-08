import 'dart:async';

import 'package:flutter/services.dart';

class FlutterImageCompress {
  static const MethodChannel _channel =
      const MethodChannel('flutter_image_compress');

  static Future<List<int>> compressWithList(List<int> image,
      {int minWidth = 1920, int minHeight = 1080, int quality = 95}) async {
    final result = await _channel.invokeMethod(
        "compressWithList", [image, minWidth, minHeight, quality]);

    return convertDynamic(result);
  }

  static Future<List<int>> compressWithFile(String path,
      {int minWidth = 1920, int minHeight = 1080, int quality = 95}) async {
    final result = await _channel
        .invokeMethod("compressWithFile", [path, minWidth, minHeight, quality]);
    return convertDynamic(result);
  }

  static List<int> convertDynamic(List<dynamic> list) {
    return list
        .where((item) => item is int)
        .map((item) => item as int)
        .toList();
  }
}
