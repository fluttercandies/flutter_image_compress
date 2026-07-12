import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Detected image container format based on file magic bytes.
enum DetectedFormat { jpeg, png, webp, heic, unknown }

/// Detect the container format of [bytes] via its magic prefix.
///
/// Sniffs are conservative: we look for the widely accepted marker set for
/// each format and treat anything else as [DetectedFormat.unknown]. This is
/// used by integration tests to assert the encoder emitted the requested
/// container without doing byte-exact goldens, which are unstable across
/// iOS/macOS versions.
DetectedFormat detectFormat(Uint8List bytes) {
  if (bytes.length < 12) return DetectedFormat.unknown;
  // JPEG: FF D8 FF
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return DetectedFormat.jpeg;
  }
  // PNG: 89 50 4E 47 0D 0A 1A 0A
  if (bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return DetectedFormat.png;
  }
  // WebP: 'RIFF' .... 'WEBP'
  if (bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return DetectedFormat.webp;
  }
  // HEIC: bytes 4..8 spell 'ftyp' + one of the HEIF-family brands at [8..12].
  if (bytes[4] == 0x66 &&
      bytes[5] == 0x74 &&
      bytes[6] == 0x79 &&
      bytes[7] == 0x70) {
    final brand = String.fromCharCodes(bytes.sublist(8, 12));
    const heifBrands = <String>{
      'heic',
      'heix',
      'hevc',
      'hevx',
      'mif1',
      'msf1',
      'heim',
      'heis',
    };
    if (heifBrands.contains(brand)) return DetectedFormat.heic;
  }
  return DetectedFormat.unknown;
}

/// Simple width/height pair for tests that only need the decoded dimensions.
class ImageDimensions {
  const ImageDimensions(this.width, this.height);
  final int width;
  final int height;
  @override
  String toString() => '${width}x$height';
}

/// Decode [bytes] via `dart:ui` and return the first-frame dimensions.
///
/// Throws if the bytes cannot be decoded by the Flutter engine. Callers
/// should not depend on Flutter decoding HEIC on every host — HEIC decode
/// support is engine-version dependent; tests that need HEIC dimensions
/// should first convert to JPEG.
Future<ImageDimensions> decodeDimensions(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      return ImageDimensions(image.width, image.height);
    } finally {
      image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

/// Load a bundled asset image as raw bytes.
Future<Uint8List> loadAssetBytes(String assetKey) async {
  final data = await rootBundle.load(assetKey);
  return data.buffer.asUint8List();
}

/// Read the EXIF property keys embedded in [bytes], via the test-only
/// native helper channel. Returns an empty list when the image has no EXIF
/// dictionary, or on platforms where the helper is not registered.
///
/// The helper is intentionally scoped to the example app and is not part of
/// the plugin API surface. See [testHelperChannel].
Future<List<String>> readExifKeys(Uint8List bytes) async {
  final result = await testHelperChannel.invokeMethod<List<Object?>>(
    'readExifKeys',
    bytes,
  );
  if (result == null) return const <String>[];
  return result.whereType<String>().toList(growable: false);
}

/// Scan [bytes] as a decoded image and return whether *any* pixel has an
/// alpha channel value below 255 (i.e. at least one non-opaque pixel).
///
/// Used by the transparency test to verify the encoder preserved alpha
/// through the compression pipeline without depending on knowing which
/// exact pixel is transparent in the source.
Future<bool> imageHasAlpha(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  try {
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return false;
      final total = image.width * image.height;
      for (var i = 0; i < total; i++) {
        if (data.getUint8(i * 4 + 3) < 255) return true;
      }
      return false;
    } finally {
      image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

const MethodChannel testHelperChannel =
    MethodChannel('flutter_image_compress/test');

/// Return a scratch directory the tests can write into safely.
///
/// On macOS-sandboxed builds, the container's Caches directory returned by
/// `getTemporaryDirectory()` may not exist on first launch (a fresh CI
/// runner exercises this — a locally launched app happens to have created
/// the directory already on prior runs). Create it first so writes are
/// reliable across hosts.
Future<Directory> ensureScratchDirectory() async {
  final dir = await getTemporaryDirectory();
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}

/// Assert compressed output is a well-formed member of the requested format.
///
/// Callers pass in a [description] used only for failure context. This wraps
/// the common preflight checks that every test in the suite performs so an
/// unrelated regression (empty output, wrong container) is caught up front
/// with a clear error rather than showing up as a downstream decode failure.
void expectValidCompressed({
  required Uint8List bytes,
  required DetectedFormat expected,
  required String description,
}) {
  if (bytes.isEmpty) {
    throw StateError('[$description] compressed output was empty');
  }
  final detected = detectFormat(bytes);
  if (detected != expected) {
    final hex = bytes
        .take(16)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');
    throw StateError(
      '[$description] expected format=$expected but detected=$detected '
      '(first 16 bytes: $hex)',
    );
  }
}
