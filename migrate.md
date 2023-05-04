# Migrate document

## 1.x to 2.x

There are several changes

- The return value of `File` is now changed to the `XFile` type of [cross_file][], so you need to change the code to `XFile`.

1.0:

```dart
final File file = FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
      rotate: 90,
    );

int length = file.lengthSync();
Uint8List buffer = file.readAsBytesSync();
```

2.0:

```dart
final XFile file = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
      rotate: 90,
    );

int length = await file.length();
Uint8List buffer = await file.readAsBytes();
```

Other usage of `XFile` to see [document][xfile]

[cross_file]: https://pub.dev/packages/cross_file
[xfile]: https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html
