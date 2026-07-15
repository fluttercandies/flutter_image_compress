import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';

import 'compress_format.dart';

class FlutterImageCompressValidator {
  FlutterImageCompressValidator(this.channel);

  final MethodChannel channel;

  bool ignoreCheckExtName = false;
  bool ignoreCheckSupportPlatform = false;

  void checkFileNameAndFormat(String name, CompressFormat format) {
    if (ignoreCheckExtName) {
      return;
    }
    final lower = name.toLowerCase();
    late final Iterable<String> allowedExts;
    late final String formatLabel;
    if (format == CompressFormat.jpeg) {
      allowedExts = const ['.jpg', '.jpeg'];
      formatLabel = 'jpeg';
    } else if (format == CompressFormat.png) {
      allowedExts = const ['.png'];
      formatLabel = 'png';
    } else if (format == CompressFormat.heic) {
      allowedExts = const ['.heic'];
      formatLabel = 'heic';
    } else if (format == CompressFormat.webp) {
      allowedExts = const ['.webp'];
      formatLabel = 'webp';
    } else {
      return;
    }
    final ok = allowedExts.any(lower.endsWith);
    if (!ok) {
      final expected = allowedExts.join(' or ');
      final msg =
          'CompressFormat.$formatLabel requires the target file name to end '
          'with $expected. Got: "$name". '
          'If you deliberately want to bypass this check (for example the '
          'target extension does not match the encoded format), set '
          'FlutterImageCompress.validator.ignoreCheckExtName = true.';
      assert(false, msg);
      throw ArgumentError.value(name, 'name', msg);
    }
  }

  Future<bool> checkSupportPlatform(CompressFormat format) async {
    if (ignoreCheckSupportPlatform) {
      return true;
    }
    if (format == CompressFormat.heic) {
      if (Platform.isIOS) {
        final String version = await channel.invokeMethod('getSystemVersion');
        final firstVersion = version.split('.')[0];
        final result = int.parse(firstVersion) >= 11;
        const msg = 'The heic format only support iOS 11.0+';
        assert(result, msg);
        _checkThrowError(result, msg);
        return result;
      } else if (Platform.isAndroid) {
        final int version = await channel.invokeMethod('getSystemVersion');
        final result = version >= 28;
        const msg = 'The heic format only support android API 28+';
        assert(result, msg);
        _checkThrowError(result, msg);
        return result;
      } else {
        const msg = 'The heic format only support Android and iOS.';
        assert(Platform.isAndroid || Platform.isIOS, msg);
        _checkThrowError(false, msg);
        return false;
      }
    } else if (format == CompressFormat.webp) {
      if (Platform.isAndroid || Platform.isIOS) {
        return true;
      }
      const msg = 'The webp format only support android and iOS.';
      _checkThrowError(false, msg);
      return false;
    }
    return true;
  }

  void _checkThrowError(bool result, String msg) {
    if (!result) {
      throw UnsupportedError(msg);
    }
  }
}
