# flutter_image_compress

compress image with native code(objc kotlin)

## why
Q：Dart has image related libraries to compress. Why use native?

A：For efficiency reasons, the compression efficiency of some dart libraries is not high, and it will be stuck to UI, even if isolate is used.

## use

```yaml
dependencies:
  flutter_image_compress: ^0.1.0
```

```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';
```


compress with file path
```dart
 var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    File file = File("test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path, // file path
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
    ); // compress
    print(file.lengthSync());
    print(result.length);
```


compress with list
```dart
  Future<void> compress() async {
    var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);

    var beforeCompress = data.lengthInBytes;
    print("beforeCompress = $beforeCompress");

    var result =
        await FlutterImageCompress.compressWithList(
      data.buffer.asUint8List(), //list 
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
    );

    print("after = ${result?.length ?? 0}");
  }
```