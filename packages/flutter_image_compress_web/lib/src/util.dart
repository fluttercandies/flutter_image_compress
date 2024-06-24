library util;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

extension Uint8ListExtension on Uint8List {
  Future<ImageBitmap> toImageBitmap() async {
    final buffer = this;
    final blob = Blob([buffer.toJS].toJS);
    final bitmap = await window.createImageBitmap(blob).toDart;
    return bitmap;
  }
}
