@JS()
library window;

import 'dart:html';
import 'dart:js';
import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS()
@staticInterop
class JSWindow {}

extension JSWindowExtension on JSWindow {
  external Function get createImageBitmap;
  external Function get pica;
}

Future<ImageBitmap> convertUint8ListToBitmap(Uint8List buffer) async {
  final blob = Blob([buffer]);

  var jsWindow = window as JSWindow;
  final result = await jsWindow.createImageBitmap(blob);
  final bitmap = await promiseToFuture(result);
  return bitmap;
}

extension FutureDynamicExtension on dynamic {
  Future<T> toFuture<T>() => promiseToFuture(this);
}
