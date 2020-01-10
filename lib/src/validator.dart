import 'dart:io';

import 'compress_format.dart';

class Validator {
  void checkFileNameAndFormat(String name, CompressFormat format) {
    if (format == CompressFormat.jpeg) {
      assert((name.endsWith(".jpg") || name.endsWith(".jpeg")),
          "The jpeg format name must end with jpg or jpeg.");
    } else if (format == CompressFormat.png) {
      assert(name.endsWith(".png"), "The jpeg format name must end with png.");
    } else if (format == CompressFormat.heic) {
      assert(
          name.endsWith(".heic"), "The heic format name must end with heic.");
    }
  }

  void checkSupportPlatform(CompressFormat format) {
    if (format == CompressFormat.heic) {
      assert(Platform.isIOS, "The heic only support iOS.");
    }
  }
}
