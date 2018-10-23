import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class FlutterImageCompress {
  static const MethodChannel _channel =
      const MethodChannel('flutter_image_compress');

  static Future<List<int>> compressWithList(
    List<int> image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
  }) async {
    final result = await _channel.invokeMethod("compressWithList", [
      image,
      minWidth,
      minHeight,
      quality,
      rotate,
    ]);

    return convertDynamic(result);
  }

  static Future<List<int>> compressWithFile(
    String path, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
  }) async {
    final result = await _channel.invokeMethod("compressWithFile", [
      path,
      minWidth,
      minHeight,
      quality,
      rotate,
    ]);
    return convertDynamic(result);
  }

  static Future<File> compressAndGetFile(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
  }) async {
    if (!File(path).existsSync()) {
      return null;
    }
    
    final String result =
        await _channel.invokeMethod("compressWithFileAndGetFile", [
      path,
      minWidth,
      minHeight,
      quality,
      targetPath,
      rotate,
    ]);

    return File(result);
  }

  static Future<List<int>> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
  }) async {
    var img = AssetImage(assetName);
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);

    return compressWithList(
      data.buffer.asUint8List(),
      minHeight: minHeight,
      minWidth: minWidth,
      quality: quality,
    );
  }
  // static Future<List<int>> compressWithImage(BuildContext context, Image image,
  //     {int minWidth = 1920, int minHeight = 1080, int quality = 95}) async {
  //   var info = await getImageInfo(context, image.image);
  //   var data = await info.image.toByteData(format: ImageByteFormat.png);
  //   var list = data.buffer.asUint8List().toList();
  //   // print(list);
  //   var result = await compressWithList(
  //     list,
  //     minWidth: minWidth,
  //     minHeight: minHeight,
  //     quality: quality,
  //   );
  //   print(result.length);
  //   return [];
  // }

  // static Future<List<int>> _compressWithImageProvider(
  //     BuildContext context, ImageProvider provider,
  //     {int minWidth = 1920, int minHeight = 1080, int quality = 95}) async {
  //   var info = await getImageInfo(context, provider);
  //   var data = await info.image.toByteData();
  //   var list = data.buffer.asUint8List().toList();

  //   return compressWithList(
  //     list,
  //     minWidth: minWidth,
  //     minHeight: minHeight,
  //     quality: quality,
  //   );
  // }

  static List<int> convertDynamic(List<dynamic> list) {
    return list
        .where((item) => item is int)
        .map((item) => item as int)
        .toList();
  }
}

Future<ImageInfo> getImageInfo(BuildContext context, ImageProvider provider,
    {Size size}) async {
  final ImageConfiguration config =
      createLocalImageConfiguration(context, size: size);
  final Completer<ImageInfo> completer = new Completer<ImageInfo>();
  final ImageStream stream = provider.resolve(config);
  void listener(ImageInfo image, bool sync) {
    completer.complete(image);
  }

  void errorListener(dynamic exception, StackTrace stackTrace) {
    completer.complete(null);
    FlutterError.reportError(new FlutterErrorDetails(
      context: 'image load failed ',
      library: 'flutter_image_compress',
      exception: exception,
      stack: stackTrace,
      silent: true,
    ));
  }

  stream.addListener(listener, onError: errorListener);
  completer.future.then((ImageInfo info) {
    stream.removeListener(listener);
  });
  return completer.future;
}
