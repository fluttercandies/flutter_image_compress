# flutter_image_compress

[![ImageCompress](https://img.shields.io/badge/fluttercandies-ImageCompress-blue.svg)](https://github.com/fluttercandies/flutter_image_compress)
[![pub package](https://img.shields.io/pub/v/flutter_image_compress.svg)](https://pub.dartlang.org/packages/flutter_image_compress)
[![GitHub license](https://img.shields.io/github/license/fluttercandies/flutter_image_compress?style=flat-square)](https://github.com/fluttercandies/flutter_image_compress/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_image_compress.svg?style=social&label=Stars)](https://github.com/fluttercandies/flutter_image_compress)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![FlutterCandies](https://pub.idqqimg.com/wpa/images/group.png)](https://jq.qq.com/?_wv=1027&k=5bcc0gy)

A Flutter plugin that compresses images using native code (Kotlin on Android, Objective-C/Swift on Apple platforms). Supported platforms: Android, iOS, macOS, Web, OpenHarmony.

<details>
<summary>Table of contents</summary>

- [Why native instead of Dart?](#why-native-instead-of-dart)
- [Platform features](#platform-features)
- [Usage](#usage)
- [Common parameters](#common-parameters)
  - [minWidth and minHeight](#minwidth-and-minheight)
  - [rotate](#rotate)
  - [autoCorrectionAngle](#autocorrectionangle)
  - [quality](#quality)
  - [format](#format)
    - [WebP](#webp)
    - [HEIF / HEIC](#heif--heic)
  - [inSampleSize](#insamplesize)
  - [keepExif](#keepexif)
- [Return values](#return-values)
  - [Working with `List<int>` and `Uint8List`](#working-with-listint-and-uint8list)
- [FAQ](#faq)
- [Runtime errors](#runtime-errors)
- [Android](#android)
- [Troubleshooting](#troubleshooting)
- [EXIF metadata](#exif-metadata)
- [Web](#web)
- [macOS](#macos)
- [OpenHarmony](#openharmony)

</details>

## Why native instead of Dart?

Dart-only image libraries exist, but in practice they are too slow for typical compression workloads — even in release builds, and even when moved to an `Isolate`. Delegating to platform-native encoders is dramatically faster.

## Platform features

| Feature                    | Android |  iOS  |           Web           | macOS | OpenHarmony |
| :------------------------- | :-----: | :---: | :---------------------: | :---: | :---------: |
| `compressWithList`         |    ✅   |   ✅   |            ✅            |   ✅   |      ✅      |
| `compressAssetImage`       |    ✅   |   ✅   |            ✅            |   ✅   |      ✅      |
| `compressWithFile`         |    ✅   |   ✅   |            ❌            |   ✅   |      ✅      |
| `compressAndGetFile`       |    ✅   |   ✅   |            ❌            |   ✅   |      ✅      |
| Format: jpeg               |    ✅   |   ✅   |            ✅            |   ✅   |      ✅      |
| Format: png                |    ✅   |   ✅   |            ✅            |   ✅   |      ✅      |
| Format: webp               |    ✅   |   ✅   | [🌐][webp-compatibility] |   ❌   |      ✅      |
| Format: heic               |    ✅   |   ✅   |            ❌            |   ✅   |      ✅      |
| Param: `quality`           |    ✅   |   ✅   | [🌐][webp-compatibility] |   ✅   |      ✅      |
| Param: `rotate`            |    ✅   |   ✅   |            ❌            |   ✅   |      ✅      |
| Param: `keepExif`          |    ✅   |   ✅   |            ❌            |   ✅   |      ❌      |

[webp-compatibility]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob#browser_compatibility "Browser support"


## Usage

Add the [latest version](https://pub.dev/packages/flutter_image_compress/versions) to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_image_compress: <latest_version>
```

Or run:

```bash
flutter pub add flutter_image_compress
```

Import it in your Dart code:

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';
```

The plugin exposes four entry points depending on your input and desired output. See the [full example](https://github.com/fluttercandies/flutter_image_compress/blob/main/packages/flutter_image_compress/example/lib/main.dart) for a runnable version.

```dart
// 1. Compress a file, get bytes back.
Future<Uint8List?> testCompressFile(File file) async {
  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 2300,
    minHeight: 1500,
    quality: 94,
    rotate: 90,
  );
  print(file.lengthSync());
  if (result != null) {
    print(result.length);
  }
  return result;
}

// 2. Compress a file, get a file back.
Future<File?> testCompressAndGetFile(File file, String targetPath) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 88,
    rotate: 180,
  );

  print(file.lengthSync());
  if (result != null) {
    print(await result.length());
    return File(result.path);
  }
  return result;
}

// 3. Compress an asset image, get bytes back.
Future<Uint8List?> testCompressAsset(String assetName) async {
  return FlutterImageCompress.compressAssetImage(
    assetName,
    minHeight: 1920,
    minWidth: 1080,
    quality: 96,
    rotate: 180,
  );
}

// 4. Compress bytes, get bytes back.
Future<Uint8List> testCompressList(Uint8List list) async {
  final result = await FlutterImageCompress.compressWithList(
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

## Common parameters

### minWidth and minHeight

`minWidth` and `minHeight` bound the output size while preserving the source aspect ratio. See the [FAQ entry below](#why-is-minwidthminheight-named-that-if-it-acts-like-a-max) for why the names are misleading.

Given a 4000×2000 image with `minWidth: 1920, minHeight: 1080`, the scale is computed like this:

```dart
// Illustrative Dart port of the native logic.
import 'dart:math' as math;

void main() {
  final scale = calcScale(
    srcWidth: 4000,
    srcHeight: 2000,
    minWidth: 1920,
    minHeight: 1080,
  );

  print('scale = $scale'); // 1.8518518518518519
  print('target = ${4000 / scale} × ${2000 / scale}'); // 2160.0 × 1080.0
}

double calcScale({
  required double srcWidth,
  required double srcHeight,
  required double minWidth,
  required double minHeight,
}) {
  final scaleW = srcWidth / minWidth;
  final scaleH = srcHeight / minHeight;
  return math.max(1.0, math.min(scaleW, scaleH));
}
```

If the source is already smaller than `minWidth` or `minHeight`, the scale is clamped to `1` — the image is never upscaled.

### rotate

Rotates the output by the given number of degrees. Set to `0` to skip rotation.

### autoCorrectionAngle

Available since 0.5.0. When `true` (the default), the plugin reads the source's EXIF orientation and rotates so the output is upright.

If you also pass a non-zero `rotate` value, the two can compound. To avoid double rotation, either set `rotate: 0` or `autoCorrectionAngle: false`.

### quality

Target quality, `0`–`100`. Ignored for PNG on iOS (PNG is lossless there).

### format

Chosen via the `CompressFormat` enum. Defaults to JPEG. JPEG and PNG work everywhere; WebP and HEIC have platform caveats — see below.

#### WebP

- **Android**: uses the system encoder, which is fast.
- **iOS**: encoded via [SDWebImageWebPCoder](https://github.com/SDWebImage/SDWebImageWebPCoder). Functional, but noticeably slower than the other formats. Swapping to Google's `libwebp` directly would help but is not currently on the roadmap.
- **macOS**: not supported.
- **Web**: depends on the browser's Canvas `toBlob` implementation; see the compatibility link in the table above.

#### HEIF / HEIC

- **iOS**: iOS 11+ only.
- **Android**: API 28+ only, and requires a working hardware encoder. Not every API 28+ device qualifies — always wrap the call in try/catch and fall back to JPEG on `UnsupportedError`. Implemented on top of [`HeifWriter`][heifwriter].

[heifwriter]: https://developer.android.com/reference/androidx/heifwriter/HeifWriter.html

### inSampleSize

Android only. Passed directly to `BitmapFactory.Options`; see the [Android documentation](https://developer.android.com/reference/android/graphics/BitmapFactory.Options.html#inSampleSize) for its exact semantics.

### keepExif

When `true`, source EXIF metadata is copied onto the compressed output. Defaults to `false`.

A few caveats apply regardless of platform or format:

1. The `Orientation` tag is always normalized to `1` / `ORIENTATION_NORMAL`. The pipeline bakes any rotation into the pixels, so preserving the source orientation would cause viewers to rotate a second time.
2. Support depends on both the output format **and** the platform:

   | Output format | iOS / macOS | Android |
   | --- | --- | --- |
   | JPEG | ✅ Full sub-dict passthrough (EXIF, TIFF, GPS, IPTC, PNG) | ✅ ~90 tags via `androidx.exifinterface` |
   | PNG  | ✅ Same passthrough | ✅ ~90 tags via `androidx.exifinterface` |
   | WebP | ❌ ImageIO cannot author WebP metadata; output is a valid WebP with no EXIF | ✅ ~90 tags via `androidx.exifinterface` |
   | HEIC | ✅ Same passthrough | ❌ `androidx.exifinterface` refuses HEIF writes; output is a valid HEIC with no EXIF. `HeifHandler` logs a warning. |

3. Unsupported combinations still return valid image bytes — you simply do not get EXIF back. `keepExif: true` never fails the compression call as a whole.

##### Known gaps (tracked in [#130](https://github.com/fluttercandies/flutter_image_compress/issues/130))

- **iOS WebP + `keepExif`**: ImageIO cannot write metadata into a WebP container. A manual VP8X + EXIF chunk splice via `SDWebImageWebPCoder` would fix this but is not implemented.
- **Android HEIC + `keepExif`**: `androidx.exifinterface` refuses HEIF writes on every version. Manually injecting ISO/IEC 23008-12 metadata boxes (~400 LoC) would fix this but is not implemented.
- **Web / OpenHarmony `keepExif`**: the Canvas / packing pipelines strip metadata at encode time — no in-tree fix path exists.

## Return values

APIs that return a `List<int>` never return `null` — they return an empty list when compression fails.

APIs that return a file may return `null`. The file may also be missing on disk even when a value is returned, so verify existence before using it.

### Working with `List<int>` and `Uint8List`

You'll often need to convert `List<int>` to `Uint8List` to display the result:

```dart
final image = Uint8List.fromList(imageList);
final ImageProvider provider = MemoryImage(image);
```

Import `dart:typed_data` (or `flutter/foundation.dart`) to get `Uint8List`:

![img](https://raw.githubusercontent.com/CaiJingLong/asset_for_picgo/master/20190519111735.png)

Displaying the result in an `Image` widget:

```dart
Future<Widget> _compressImage() async {
  final List<int> image = await testCompressFile(file);
  final ImageProvider provider = MemoryImage(Uint8List.fromList(image));
  return Image(image: provider);
}
```

Writing the result to disk:

```dart
Future<void> writeToFile(List<int> image, String filePath) {
  return File(filePath).writeAsBytes(image, flush: true);
}
```

## FAQ

### Compressing to a target file size

Neither `quality` (0–100, lossy) nor `minWidth`/`minHeight` (max output dimensions) maps linearly to output bytes. If you need to hit a specific size limit, iterate:

```dart
Future<Uint8List> compressToUnder(Uint8List src, int limitBytes) async {
  var quality = 88;
  var out = src;
  while (quality > 10) {
    out = await FlutterImageCompress.compressWithList(
      src,
      quality: quality,
      minWidth: 1920,
      minHeight: 1920,
    );
    if (out.lengthInBytes <= limitBytes) return out;
    quality -= 10;
  }
  return out;
}
```

For very small targets, shrink `minWidth`/`minHeight` as well once the quality loop bottoms out — pixel count is usually the biggest lever on file size.

### Why is `minWidth`/`minHeight` named that if it acts like a max?

Historical name we're stuck with. In practice they are **aspect-preserving upper bounds** on the output: the pipeline scales down (never up) so both dimensions fit inside the given box while keeping the source aspect ratio. Examples:

- Source 4032×3024, `minWidth: 1920, minHeight: 1920` → output ~1920×1440.
- Source 1000×1000, `minWidth: 500, minHeight: 500`   → output 500×500.
- Source 800×600,  `minWidth: 1920, minHeight: 1080`  → output 800×600 (no upscale).

The aspect ratio is always preserved (never cropped); only the scale is adjusted.

### The compressed image is larger than the original

Two common causes:

- **Re-encoding PNG as PNG.** PNG is lossless — re-encoding rarely shrinks it unless you also downscale. `quality` has no effect on PNG in the underlying encoders; the same DEFLATE runs either way. If the source was already tightly encoded (e.g. via `pngcrush`), the output can be a few percent larger.
- **`minWidth`/`minHeight` larger than the source.** The plugin won't upscale, but re-encoding still runs and may produce a slightly larger file than the input.

If the source is already small enough, skip the call when `src.lengthInBytes` is below your threshold rather than always compressing.

### Calling from a background isolate / `compute()`

Platform channels don't work in a background isolate unless you initialize its binary messenger first. Inside the isolate:

```dart
BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
final out = await FlutterImageCompress.compressWithList(bytes, quality: 80);
```

Obtain `rootIsolateToken` on the main isolate via `RootIsolateToken.instance!` and pass it in through the isolate's arguments.

Without this step you'll see an `UnimplementedError` pointing back here — that's the platform interface's `UnsupportedFlutterImageCompress` fallback firing.

### Which platforms support which formats?

Full matrix in [Platform features](#platform-features). Quick reference:

- **JPEG / PNG**: everywhere.
- **WebP**: Android + iOS + macOS via SDWebImageWebPCoder, Web via the browser (quality support varies).
- **HEIC / HEIF**: iOS 11+ and Android API 28+ with a hardware encoder — throws `UnsupportedError` otherwise. Not on macOS.

### How do I clear the temp files the plugin creates?

`compressAndGetFile` writes to the `targetPath` you pass. Everything else lands in the OS cache directory (`context.cacheDir` on Android, `NSTemporaryDirectory()` on iOS). Both are OS-managed; if you want manual cleanup, use [`path_provider`](https://pub.dev/packages/path_provider)'s `getTemporaryDirectory()` and clear it yourself.

## Runtime errors

Format and platform support vary, so any API may throw `UnsupportedError` on a device that can't produce the requested format. If you rely on WebP or HEIC, catch it and fall back to JPEG:

```dart
Future<Uint8List> compressAndTryCatch(String path) async {
  try {
    return await FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.heic,
    );
  } on UnsupportedError catch (e) {
    print(e);
    return FlutterImageCompress.compressWithFile(
      path,
      format: CompressFormat.jpeg,
    );
  }
}
```

## Android

Requires Kotlin `1.5.21` or higher.

## Troubleshooting

### Compressing returns `null`

Usually a filesystem issue. Check that:

- Your process can read the source file and write to the target path.
- The parent directory of the target path exists.
- You've requested any permissions the platform needs (e.g. SD-card access on Android).

Use [`path_provider`](https://pub.dev/packages/path_provider) to obtain writable app directories, and a permission plugin for runtime storage permissions.

## EXIF metadata

By default (`keepExif: false`), the compressed output carries no source EXIF — only the minimum the container encoder injects (image dimensions, color space, and so on).

With `keepExif: true`, the plugin copies source EXIF onto the output. The [keepExif section](#keepexif) has the full per-format, per-platform matrix. In short:

- **iOS + macOS**: full sub-dict passthrough (EXIF, TIFF, GPS, IPTC, PNG chunks) via `CGImageSource → CGImageDestination`. Works for JPEG, PNG, HEIC. Not WebP — ImageIO cannot author WebP metadata.
- **Android**: ~90-tag copy via `androidx.exifinterface`. Works for JPEG, PNG, WebP. Not HEIC — `ExifInterface` refuses HEIF writes and `HeifHandler` logs a warning.
- **Web + OpenHarmony**: not supported. The Canvas / packing pipelines strip metadata at encode time.

Regardless of platform, the `Orientation` tag is always normalized to `1` / `ORIENTATION_NORMAL` on the output — the pipeline bakes rotation into pixels, so preserving the source orientation would cause viewers to rotate a second time.

### Encoders in use

- **JPEG / PNG**: system APIs on every platform.
- **WebP**: system API on Android; [SDWebImageWebPCoder](https://github.com/SDWebImage/SDWebImageWebPCoder) on iOS; browser Canvas on Web.
- **HEIC / HEIF**: ImageIO on iOS 11+; [HeifWriter](https://developer.android.com/jetpack/androidx/releases/heifwriter) on Android API 28+ with a hardware encoder (throws `UnsupportedError` when the device can't encode HEIC).

## Web

The web implementation is optional — most consumers don't need it. It relies on the browser's Canvas `toBlob`, so format and quality support depend on the browser (see the compatibility link in the [Platform features](#platform-features) table).

## macOS

Requires a minimum deployment target of macOS 10.15. To update an existing app:

1. Open the Xcode project, select the **Runner** target, and set **macOS Deployment Target** to `10.15`.
2. Update `Podfile` to `platform :osx, '10.15'`.

## OpenHarmony

Decoding supports JPEG, PNG, GIF, RAW, WebP, BMP, and SVG. Encoding output is currently limited to JPEG, PNG, and WebP.

当前支持的解析图片格式包括 JPEG、PNG、GIF、RAW、WebP、BMP、SVG。编码输出图片格式当前仅支持 JPEG、PNG 和 WebP。
