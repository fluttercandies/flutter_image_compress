# flutter_image_compress

[![pub package](https://img.shields.io/pub/v/flutter_image_compress.svg)](https://pub.dartlang.org/packages/flutter_image_compress)
![GitHub](https://img.shields.io/github/license/OpenFlutter/flutter_image_compress.svg)
[![GitHub stars](https://img.shields.io/github/stars/OpenFlutter/flutter_image_compress.svg?style=social&label=Stars)](https://github.com/OpenFlutter/flutter_image_compress)

compress image with native code(objc kotlin)

This library can work on android/ios.

## why

Q：Dart has image related libraries to compress. Why use native?

A：For reasons unknown, using dart language is not efficient, even in release version, using isolate can not solve the problem.

## about android

maybe, you need update your kotlin version to `1.2.71` or higher.

## about ios

No problems found at present.

## use

```yaml
dependencies:
  flutter_image_compress: ^0.2.3
```

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';
```

use:

[see whole example code](https://github.com/OpenFlutter/flutter_image_compress/blob/master/example/lib/main.dart)

```dart
  Future<List<int>> testCompressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
      rotate: 90,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 88,
        rotate: 180,
      );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future<List<int>> testCompressAsset(String assetName) async {
    var list = await FlutterImageCompress.compressAssetImage(
      assetName,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
      rotate: 180,
    );

    return list;
  }

  Future<List<int>> testComporessList(List<int> list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
      rotate: 135,
    );
    print(list.length);
    print(result.length);
    return result;
  }
```

## about List<int> or Uint8List

you maybe need convert `List<int>` to 'Uint8List' to display image

use Uint8List need import package to your code like this

![](https://ws1.sinaimg.cn/large/844036b9ly1fxhyu2opqqj20j802c3yr.jpg)

```dart
var u8 = Uint8List.fromList(list)
ImageProvider provider = MemoryImage(Uint8List.fromList(list));
```

use in `Image` Widget

```dart
    List<int> list = await testCompressFile(file);
    ImageProvider provider = MemoryImage(Uint8List.fromList(list));

    Image(
      image: provider ?? AssetImage("img/img.jpg"),
    ),
```

write to file

```dart
  void writeToFile(List<int> list, String filePath) {
    var file = File(filePath);
    file.writeAsBytes(list, flush: true, mode: FileMode.write);
  }
```

## android build error

```
Caused by: org.gradle.internal.event.ListenerNotificationException: Failed to notify project evaluation listener.
        at org.gradle.internal.event.AbstractBroadcastDispatch.dispatch(AbstractBroadcastDispatch.java:86)
        ...
Caused by: java.lang.AbstractMethodError
        at org.jetbrains.kotlin.gradle.plugin.KotlinPluginKt.resolveSubpluginArtifacts(KotlinPlugin.kt:776)
        ...
```

see the [flutter/flutter/issues#21473](https://github.com/flutter/flutter/issues/21473#issuecomment-420434339)

you need edit your kotlin version to 1.2.71+

If flutter supports more platforms (windows, mac, linux, other) in the future and you use this library, propose issue / PR

## ABOUT EXIF

Using this library, EXIF information will be removed.
