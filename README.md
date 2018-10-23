# flutter_image_compress

compress image with native code(objc kotlin)

## why

Q：Dart has image related libraries to compress. Why use native?

A：For efficiency reasons, the compression efficiency of some dart libraries is not high, and it will be stuck to UI, even if isolate is used.

## use

```yaml
dependencies:
  flutter_image_compress: ^0.1.5
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

## about List<int>

you maybe need convert `List<int>` to 'Uint8List'

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
