# flutter_image_compress

This Go package implements the host-side of the Flutter [flutter_image_compress](https://github.com/fluttercandies/flutter_image_compress) plugin.

## Usage

Import as:

```go
import flutter_image_compress "github.com/fluttercandies/flutter_image_compress/go"
```

Then add the following option to your go-flutter [application options](https://github.com/go-flutter-desktop/go-flutter/wiki/Plugin-info):

```go
flutter.AddPlugin(&flutter_image_compress.ImageCompressPlugin{}),
```

## Support

- [x] fileToFile
- [x] listToList
- [x] listToFile

- [x] minWidth
- [x] minHeight
- [x] rotate
- [x] quality

- [x] jpeg
- [x] png

- [ ] keepExif
- [ ] autoCorrectionAngle
