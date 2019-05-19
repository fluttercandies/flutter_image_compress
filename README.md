# flutter_image_compress

[![ImageCompress](https://img.shields.io/badge/OpenFlutter-ImageCompress-blue.svg)](https://github.com/OpenFlutter/flutter_image_compress)
[![pub package](https://img.shields.io/pub/v/flutter_image_compress.svg)](https://pub.dartlang.org/packages/flutter_image_compress)
![GitHub](https://img.shields.io/github/license/OpenFlutter/flutter_image_compress.svg)
[![GitHub stars](https://img.shields.io/github/stars/OpenFlutter/flutter_image_compress.svg?style=social&label=Stars)](https://github.com/OpenFlutter/flutter_image_compress)
[![Awesome](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)

Compresses image as native plugin (Obj-C/Kotlin)

This library can works on Android and iOS.

## Why

Q：Dart already has image compression libraries. Why use native?

A：For unknown reasons, image compression in Dart language is not efficient, even in release version. Using isolate does not solve the problem.

- [flutter_image_compress](#flutter_image_compress)
  - [Why](#why)
  - [About version](#about-version)
  - [Breaking change at version 0.5.0](#breaking-change-at-version-050)
  - [About params](#about-params)
    - [autoCorrectionAngle](#autocorrectionangle)
  - [Android](#android)
  - [iOS](#ios)
  - [Usage](#usage)
  - [Result](#result)
    - [About `List<int>` and `Uint8List`](#about-listint-and-uint8list)
  - [Troubleshooting](#troubleshooting)
    - [Compressing returns `null`](#compressing-returns-null)
  - [Android build error](#android-build-error)
  - [About EXIF information](#about-exif-information)

## About version

| flutter version | plugin version |
| --------------- | -------------- |
| 1.5.9+          | use 0.5.x+     |
| 1.5.8 or low    | 0.4.0          |

## Breaking change at version 0.5.0

Because [#46](https://github.com/OpenFlutter/flutter_image_compress/pull/46) and subsequent changes have caused the image Angle to be automatically corrected based on Exif" this default behavior conflicts with the previous argument 'rotate' to rotate the Angle based on Exif information, so I think this is a destructive change.

Because the context parameter type in Flutter ErrorDetails was modified in version 1.5.9 of flutter SDK (which has been deleted and is now modified to 1.6.0), errors will be reported in 1.5.8 and previous versions, including the current stable version (1.5.4-hotfix-2).

So, I decided to increase the version number of middles to accommodate this modification and add flutter SDK constraints.

## About params

MinWidth and minHeight are constraints on image scaling.

For example, a 4000\*2000 image, minWidth set to 1920, minHeight set to 1080, the calculation is as follows:

```dart
// Using dart as an example, the actual implementation is Kotlin or OC.
import 'dart:math' as math;

void main() {
  var scale = calcScale(
    srcWidth: 4000,
    srcHeight: 2000,
    minWidth: 1920,
    minHeight: 1080,
  );

  print("scale = $scale"); // scale = 1.8518518518518519
  print("target width = ${4000 / scale}, height = ${2000 / scale}"); // target width = 2160.0, height = 1080.0
}

double calcScale({
  double srcWidth,
  double srcHeight,
  double minWidth,
  double minHeight,
}) {
  var scaleW = srcWidth / minWidth;
  var scaleH = srcHeight / minHeight;

  var scale = math.max(1.0, math.min(scaleW, scaleH));

  return scale;
}

```

If your image width is smaller than minWidth or height samller than minHeight, scale will be 1, that is, the size will not change.

### autoCorrectionAngle

This property only exists in the version after 0.5.0.

And for historical reasons, there may be conflicts with rotate attributes, which need to be self-corrected.

Modify rotate to 0 or autoCorrectionAngle to false.

## Android

You may need to update Kotlin to version `1.2.71`(Recommend 1.3.21) or higher.

## iOS

No problems currently found.

## Usage

```yaml
dependencies:
  flutter_image_compress: ^0.4.0
```

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';
```

Use as:

[See full example](https://github.com/OpenFlutter/flutter_image_compress/blob/master/example/lib/main.dart)

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

## Result

The result of returning a List collection will not have null, but will always be an empty array.

The returned file may be null. In addition, please decide for yourself whether the file exists.

### About `List<int>` and `Uint8List`

You may need to convert `List<int>` to `Uint8List` to display images.

To use `Uint8List`, you need import package to your code like so:

![img](https://ws1.sinaimg.cn/large/844036b9ly1fxhyu2opqqj20j802c3yr.jpg)

```dart
final image = Uint8List.fromList(imageList)
ImageProvider provider = MemoryImage(Uint8List.fromList(imageList));
```

Usage in `Image` Widget:

```dart
List<int> image = await testCompressFile(file);
ImageProvider provider = MemoryImage(Uint8List.fromList(image));

Image(
  image: provider ?? AssetImage("img/img.jpg"),
),
```

Write to file usage:

```dart
void writeToFile(List<int> image, String filePath) {
  final file = File(filePath);
  file.writeAsBytes(image, flush: true, mode: FileMode.write);
}
```

## Troubleshooting

### Compressing returns `null`

Sometimes, compressing will return null. You should check if you can read/write the file, and the parent folder of the target file must exist.

For example, use the [path_provider](https://pub.dartlang.org/packages/path_provide) plugin to access some application folders, and use a permission plugin to request permission to access SD cards on Android/iOS.

## Android build error

```groovy
Caused by: org.gradle.internal.event.ListenerNotificationException: Failed to notify project evaluation listener.
        at org.gradle.internal.event.AbstractBroadcastDispatch.dispatch(AbstractBroadcastDispatch.java:86)
        ...
Caused by: java.lang.AbstractMethodError
        at org.jetbrains.kotlin.gradle.plugin.KotlinPluginKt.resolveSubpluginArtifacts(KotlinPlugin.kt:776)
        ...
```

See [flutter/flutter/issues#21473](https://github.com/flutter/flutter/issues/21473#issuecomment-420434339)

You need to upgrade your Kotlin version to `1.2.71+`.

If Flutter supports more platforms (Windows, Mac, Linux, etc) in the future and you use this library, propose an issue or PR!

## About EXIF information

Using this library, EXIF information will be removed.

Although it will not be retained, over version 0.5.0, there will be the option of "automatic angle correction", which will be turned on by default.
