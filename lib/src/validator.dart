import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';

import 'compress_format.dart';

class Validator {
  final MethodChannel channel;
  Validator(this.channel);

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

  Future<void> checkSupportPlatform(CompressFormat format) async {
    if (format == CompressFormat.heic) {
      assert(Platform.isIOS, "The heic only support iOS.");
      if (Platform.isIOS) {
        final String version = await channel.invokeMethod("getSystemVersion");
        final firstVersion = version.split(".")[0];
        assert(int.parse(firstVersion) >= 11,
            "The heic format only support ios 11.0+");
      }
    }
  }
}
