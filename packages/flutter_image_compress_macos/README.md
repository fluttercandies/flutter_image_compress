# flutter_image_compress

[![ImageCompress](https://img.shields.io/badge/fluttercandies-ImageCompress-blue.svg)](https://github.com/fluttercandies/flutter_image_compress)
[![pub package](https://img.shields.io/pub/v/flutter_image_compress.svg)](https://pub.dartlang.org/packages/flutter_image_compress)
[![GitHub license](https://img.shields.io/github/license/fluttercandies/flutter_image_compress?style=flat-square)](https://github.com/fluttercandies/flutter_image_compress/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_image_compress.svg?style=social&label=Stars)](https://github.com/fluttercandies/flutter_image_compress)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![FlutterCandies](https://pub.idqqimg.com/wpa/images/group.png)](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

Compresses image as native plugin (Obj-C/Kotlin). This library works on Android, iOS, macOS, Web, OpenHarmony.

- [flutter\_image\_compress](#flutter_image_compress)
  - [Why don't you use dart to do it](#why-dont-you-use-dart-to-do-it)
  - [Platform Features](#platform-features)
  - [Usage](#usage)
  - [About common params](#about-common-params)
    - [minWidth and minHeight](#minwidth-and-minheight)
    - [rotate](#rotate)
    - [autoCorrectionAngle](#autocorrectionangle)
    - [quality](#quality)
    - [format](#format)
      - [Webp](#webp)
      - [HEIF(Heic)](#heifheic)
        - [Heif for iOS](#heif-for-ios)
        - [Heif for Android](#heif-for-android)
    - [inSampleSize](#insamplesize)
    - [keepExif](#keepexif)
  - [Result](#result)
    - [About `List<int>` and `Uint8List`](#about-listint-and-uint8list)
  - [Runtime Error](#runtime-error)
  - [Android](#android)
  - [Troubleshooting](#troubleshooting)
    - [Compressing returns `null`](#compressing-returns-null)
  - [About EXIF information](#about-exif-information)
  - [Web](#web)
  - [About macOS](#about-macos)
  - [OpenHarmony](#openharmony)

## Why don't you use dart to do it

Q：Dart already has image compression libraries. Why use native?

A：For unknown reasons, image compression in Dart language is not efficient,
even in release version. Using isolate does not solve the problem.

## Platform Features

| Feature                    | Android |  iOS  |           Web           | macOS | OpenHarmony |
| :------------------------- | :-----: | :---: | :---------------------: | :---: | :-------: |
| method: compressWithList   |    ✅    |   ✅   |            ✅            |   ✅   |     ✅     |
| method: compressAssetImage |    ✅    |   ✅   |            ✅            |   ✅   |     ✅     |
| method: compressWithFile   |    ✅    |   ✅   |            ❌            |   ✅   |     ✅     |
| method: compressAndGetFile |    ✅    |   ✅   |            ❌            |   ✅   |     ✅     |
| format: jpeg               |    ✅    |   ✅   |            ✅            |   ✅   |     ✅     |
| format: png                |    ✅    |   ✅   |            ✅            |   ✅   |     ✅     |
| format: webp               |    ✅    |   ✅   | [🌐][webp-compatibility] |   ❌   |     ✅     |
| format: heic               |    ✅    |   ✅   |            ❌            |   ✅   |     ✅     |
| param: quality             |    ✅    |   ✅   | [🌐][webp-compatibility] |   ✅   |     ✅     |
| param: rotate              |    ✅    |   ✅   |            ❌            |   ✅   |     ✅     |
| param: keepExif            |    ✅    |   ✅   |            ❌            |   ✅   |     ❌     |

[webp-compatibility]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob#browser_compatibility "Browser support"


## Usage

See the [![pub](https://img.shields.io/pub/v/flutter_image_compress.svg)](https://pub.dev/packages/flutter_image_compress/versions) version.

```yaml
dependencies:
  flutter_image_compress: <latest_version>
```

or run this command:

```bash
flutter pub add flutter_image_compress
```

import the package in your code:

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';
```

Use as:

[See full example](https://github.com/fluttercandies/flutter_image_compress/blob/main/packages/flutter_image_compress/example/lib/main.dart)

There are several ways to use the library api.

```dart

  // 1. compress file and get Uint8List
  Future<Uint8List> testCompressFile(File file) async {
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

  // 2. compress file and get file.
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

  // 3. compress asset and get Uint8List.
  Future<Uint8List> testCompressAsset(String assetName) async {
    var list = await FlutterImageCompress.compressAssetImage(
      assetName,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
      rotate: 180,
    );

    return list;
  }

  // 4. compress Uint8List and get another Uint8List.
  Future<Uint8List> testComporessList(Uint8List list) async {
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

## About common params

### minWidth and minHeight

`minWidth` and `minHeight` are constraints on image scaling.

For example, a 4000\*2000 image, `minWidth` set to 1920,
`minHeight` set to 1080, the calculation is as follows:

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

If your image width is smaller than `minWidth` or height smaller than `minHeight`,
scale will be 1, that is, the size will not change.

### rotate

If you need to rotate the picture, use this parameter.

### autoCorrectionAngle

This property only exists in the version after 0.5.0.

And for historical reasons, there may be conflicts with rotate attributes,
which need to be self-corrected.

Modify rotate to 0 or autoCorrectionAngle to false.

### quality

Quality of target image.

If `format` is png, the param will be ignored in iOS.

### format

Supports jpeg or png, default is jpeg.

The format class sign `enum CompressFormat`.

Heif and webp Partially supported.

#### Webp

Support android by the system api (speed very nice).
The library also supports iOS. However, we're using
[third-party libraries](https://github.com/SDWebImage/SDWebImageWebPCoder),
it is not recommended due to encoding speed.
In the future, `libwebp` by google (C/C++) may be used to do coding work,
bypassing other three-party libraries, but there are no plan for that currently.

#### HEIF(Heic)

##### Heif for iOS

Only support iOS 11+.

##### Heif for Android

Use [HeifWriter][] for the implementation.

Only support API 28+.

And may require hardware encoder support,
does not guarantee that all devices _above_ API 28 are available.

[heifwriter]: https://developer.android.com/reference/androidx/heifwriter/HeifWriter.html

### inSampleSize

The param is only support android.

For a description of this parameter, see the [Android official website](https://developer.android.com/reference/android/graphics/BitmapFactory.Options.html#inSampleSize).

### keepExif

If this parameter is true, EXIF information is saved in the compressed result.

Attention should be paid to the following points:

1. Default value is false.
2. Even if set to true, the direction attribute is not included.
3. Only support jpg format, PNG format does not support.

## Result

The result of returning a List collection will not have null, but will always be an empty array.

The returned file may be null. In addition, please decide for yourself whether the file exists.

### About `List<int>` and `Uint8List`

You may need to convert `List<int>` to `Uint8List` to display images.

To use `Uint8List`, you need import package to your code like this:

![img](https://raw.githubusercontent.com/CaiJingLong/asset_for_picgo/master/20190519111735.png)

```dart
final image = Uint8List.fromList(imageList);
ImageProvider provider = MemoryImage(Uint8List.fromList(imageList));
```

Usage in `Image` Widget:

```dart
Future<Widget> _compressImage() async {
  List<int> image = await testCompressFile(file);
  ImageProvider provider = MemoryImage(Uint8List.fromList(image));
  imageWidget = Image(
    image: provider ?? AssetImage('img/img.jpg'),
  );
}
```

Write to file usage:

```dart
Future<void> writeToFile(List<int> image, String filePath) {
  return File(filePath).writeAsBytes(image, flush: true);
}
```

## Runtime Error

Because of some support issues,
all APIs will be compatible with format and system compatibility,
and an exception (`UnsupportedError`) may be thrown,
so if you insist on using webp and heic formats,
please catch the exception yourself and use it on unsupported devices jpeg compression.

Example:

```dart
Future<Uint8List> compressAndTryCatch(String path) async {
  Uint8List result;
  try {
    result = await FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.heic,
    );
  } on UnsupportedError catch (e) {
    print(e);
    result = await FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.jpeg,
    );
  }
  return result;
}
```

## Android

You may need to update Kotlin to version `1.5.21` or higher.

## Troubleshooting

### Compressing returns `null`

Sometimes, compressing will return null. You should check if you can read/write the file,
and the parent folder of the target file must exist.

For example, use the [path_provider](https://pub.dartlang.org/packages/path_provide)
plugin to access some application folders,
and use a permission plugin to request permission to access SD cards on Android/iOS.

## About EXIF information

Using this library, EXIF information will be removed by default.

EXIF information can be retained by setting keepExif to true,
but not `direction` information.

- PNG/JPEG encoder: System API.
- WebP encoder:
  - [SDWebImageWebPCoder](https://github.com/SDWebImage/SDWebImageWebPCoder) on iOS.
  - System API on Android.
- HEIF encoder: System API.
  - [HeifWriter](https://developer.android.com/jetpack/androidx/releases/heifwriter) on Android P+.

## Web

The web implementation is not required for many people,

This plugin uses [pica][] to implement compression.

Currently, [debug mode does not allow you to use the dynamic script loading scheme][flutter-126131].
And when you actually deploy, you may choose server deployment or cdn deployment, so here we suggest you add script node to head or body by yourself in your `<flutte_project>/web/index.html`.

[flutter-126131]: https://github.com/flutter/flutter/issues/126131

Add for `<flutte_project>/web/index.html`:

```html
<script src="https://cdn.jsdelivr.net/npm/pica@9.0.1/dist/pica.min.js" ></script>

<!-- or -->

<script src="https://unpkg.com/pica/dist/pica.min.js" ></script>
```

About web compatibility: two methods with file will throw an exception when used on the web.

[pica]: https://www.npmjs.com/package/pica?activeTab=readme

## About macOS

You need change the minimum deployment target to 10.15.

Open xcode project, select Runner target, and change the value of `macOS Deployment Target` to `10.15`.

And, change the `Podfile`:
Change `platform` to `platform :osx, '10.15'`.


## OpenHarmony

The currently supported image formats for parsing include JPEG, PNG, GIF, RAW, WebP, BMP, and SVG. However, the encoding output image formats are currently limited to JPEG, PNG, and WebP only.

当前支持的解析图片格式包括 JPEG、PNG、GIF、RAW、WebP、BMP、SVG . 编码输出图片格式当前仅支持 JPEG、PNG 和 WebP.


