import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('compressWithList', () {
    testWidgets(
      'JPEG default: emits JPEG, shrinks below source size, honors bounds',
      (_) async {
        final src = await loadAssetBytes('img/img.jpg');
        final result = await FlutterImageCompress.compressWithList(
          src,
          minWidth: 640,
          minHeight: 480,
          quality: 80,
        );

        expectValidCompressed(
          bytes: result,
          expected: DetectedFormat.jpeg,
          description: 'JPEG compressWithList',
        );
        expect(
          result.length,
          lessThan(src.length),
          reason: 'compressed JPEG should be smaller than source',
        );

        final dims = await decodeDimensions(result);
        // Scaling preserves aspect ratio while honoring both minWidth and
        // minHeight (source is 4000x2327, so scale=480/2327 → 826x480).
        expect(
          dims.width,
          greaterThanOrEqualTo(640),
          reason: 'minWidth=640 should be respected',
        );
        expect(
          dims.height,
          greaterThanOrEqualTo(480),
          reason: 'minHeight=480 should be respected',
        );
      },
    );

    testWidgets(
      'PNG: emits PNG, decodable, dimensions honor bounds',
      (_) async {
        final src = await loadAssetBytes('img/header.png');
        final result = await FlutterImageCompress.compressWithList(
          src,
          minWidth: 300,
          minHeight: 500,
          format: CompressFormat.png,
        );

        expectValidCompressed(
          bytes: result,
          expected: DetectedFormat.png,
          description: 'PNG compressWithList',
        );

        final dims = await decodeDimensions(result);
        expect(dims.width, greaterThanOrEqualTo(300));
        expect(dims.height, greaterThanOrEqualTo(500));
      },
    );

    testWidgets(
      'WebP: emits WebP container from a JPEG source',
      (_) async {
        final src = await loadAssetBytes('img/img.jpg');
        final result = await FlutterImageCompress.compressWithList(
          src,
          minWidth: 800,
          minHeight: 800,
          quality: 80,
          format: CompressFormat.webp,
        );

        expectValidCompressed(
          bytes: result,
          expected: DetectedFormat.webp,
          description: 'WebP compressWithList',
        );
      },
      // WebP is only implemented on iOS/Android; validator throws on macOS.
      skip: !(Platform.isIOS || Platform.isAndroid),
    );
  });

  group('compressWithFile', () {
    testWidgets('reads a file path, emits JPEG bytes', (_) async {
      final srcBytes = await loadAssetBytes('img/img.jpg');
      final dir = await ensureScratchDirectory();
      final srcFile = File(
        '${dir.path}/fic-baseline-with-file-${DateTime.now().microsecondsSinceEpoch}.jpg',
      )..writeAsBytesSync(srcBytes);

      final result = await FlutterImageCompress.compressWithFile(
        srcFile.path,
        minWidth: 640,
        minHeight: 480,
        quality: 85,
      );

      expect(result, isNotNull, reason: 'compressWithFile returned null');
      expectValidCompressed(
        bytes: result!,
        expected: DetectedFormat.jpeg,
        description: 'compressWithFile JPEG',
      );
      final dims = await decodeDimensions(result);
      expect(dims.width, greaterThanOrEqualTo(640));
      expect(dims.height, greaterThanOrEqualTo(480));
    });
  });

  group('compressAndGetFile', () {
    testWidgets('writes to targetPath and returns a readable file', (_) async {
      final srcBytes = await loadAssetBytes('img/img.jpg');
      final dir = await ensureScratchDirectory();
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final srcFile = File('${dir.path}/fic-baseline-src-$stamp.jpg')
        ..writeAsBytesSync(srcBytes);
      final targetPath = '${dir.path}/fic-baseline-out-$stamp.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        srcFile.path,
        targetPath,
        minWidth: 800,
        minHeight: 600,
        quality: 88,
      );

      expect(result, isNotNull, reason: 'compressAndGetFile returned null');
      final outFile = File(result!.path);
      expect(outFile.existsSync(), isTrue,
          reason: 'output file was not written to disk',
      );
      final outBytes = await outFile.readAsBytes();
      expectValidCompressed(
        bytes: outBytes,
        expected: DetectedFormat.jpeg,
        description: 'compressAndGetFile JPEG',
      );
      final dims = await decodeDimensions(outBytes);
      expect(dims.width, greaterThanOrEqualTo(800));
      expect(dims.height, greaterThanOrEqualTo(600));
    });
  });

  group('compressAssetImage', () {
    testWidgets('reads an asset key, emits JPEG bytes', (_) async {
      final result = await FlutterImageCompress.compressAssetImage(
        'img/img.jpg',
        minWidth: 640,
        minHeight: 480,
        quality: 85,
      );
      expect(result, isNotNull, reason: 'compressAssetImage returned null');
      final bytes = Uint8List.fromList(result!);
      expectValidCompressed(
        bytes: bytes,
        expected: DetectedFormat.jpeg,
        description: 'compressAssetImage JPEG',
      );
      final dims = await decodeDimensions(bytes);
      expect(dims.width, greaterThanOrEqualTo(640));
      expect(dims.height, greaterThanOrEqualTo(480));
    });
  });

  group(
    'HEIC round-trip',
    () {
      testWidgets('JPEG -> HEIC -> JPEG round-trip is decodable', (_) async {
        final srcBytes = await loadAssetBytes('img/img.jpg');
        final dir = await ensureScratchDirectory();
        final stamp = DateTime.now().microsecondsSinceEpoch;
        final srcPath = '${dir.path}/fic-baseline-heic-src-$stamp.jpg';
        final heicPath = '${dir.path}/fic-baseline-heic-out-$stamp.heic';
        final jpgPath = '${dir.path}/fic-baseline-heic-rt-$stamp.jpg';
        File(srcPath).writeAsBytesSync(srcBytes);

        final heicResult = await FlutterImageCompress.compressAndGetFile(
          srcPath,
          heicPath,
          format: CompressFormat.heic,
          minWidth: 800,
          minHeight: 600,
          quality: 85,
        );
        expect(heicResult, isNotNull, reason: 'HEIC compressAndGetFile failed');
        final heicBytes = await File(heicResult!.path).readAsBytes();
        expectValidCompressed(
          bytes: heicBytes,
          expected: DetectedFormat.heic,
          description: 'HEIC compressAndGetFile',
        );

        final jpgResult = await FlutterImageCompress.compressAndGetFile(
          heicResult.path,
          jpgPath,
          format: CompressFormat.jpeg,
          minWidth: 400,
          minHeight: 300,
          quality: 85,
        );
        expect(jpgResult, isNotNull,
            reason: 'round-trip HEIC->JPEG returned null',);
        final jpgBytes = await File(jpgResult!.path).readAsBytes();
        expectValidCompressed(
          bytes: jpgBytes,
          expected: DetectedFormat.jpeg,
          description: 'HEIC->JPEG round-trip',
        );
        final dims = await decodeDimensions(jpgBytes);
        expect(dims.width, greaterThanOrEqualTo(400));
        expect(dims.height, greaterThanOrEqualTo(300));
      });
    },
    // Validator constrains HEIC to iOS/Android; macOS throws
    // UnsupportedError. Android is out of scope for this SPM baseline.
    skip: !Platform.isIOS,
  );

  group(
    'rotate',
    () {
      // Rotation runs *after* scaling; comparing base (rotate=0) to a
      // rotated variant lets us assert the swap/preserve invariant without
      // depending on the exact scaled dimensions the plugin picks. A ±1
      // tolerance covers the plugin's use of a floating-point bounding-box
      // for the rotated frame, which can round to N+1 pixels.
      const rotateTolerance = 1;

      Matcher approxEquals(int expected) => allOf(
            greaterThanOrEqualTo(expected - rotateTolerance),
            lessThanOrEqualTo(expected + rotateTolerance),
          );

      testWidgets(
        'rotate=90 swaps width/height relative to the unrotated output',
        (_) async {
          final src = await loadAssetBytes('img/img.jpg');
          final base = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 800,
            minHeight: 800,
            quality: 85,
          );
          final rotated = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 800,
            minHeight: 800,
            quality: 85,
            rotate: 90,
          );
          final baseDims = await decodeDimensions(base);
          final rotDims = await decodeDimensions(rotated);
          expect(rotDims.width, approxEquals(baseDims.height),
              reason: 'rotate=90 should swap width/height',);
          expect(rotDims.height, approxEquals(baseDims.width));
        },
      );

      testWidgets(
        'rotate=180 preserves width/height',
        (_) async {
          final src = await loadAssetBytes('img/img.jpg');
          final base = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 800,
            minHeight: 800,
            quality: 85,
          );
          final rotated = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 800,
            minHeight: 800,
            quality: 85,
            rotate: 180,
          );
          final baseDims = await decodeDimensions(base);
          final rotDims = await decodeDimensions(rotated);
          expect(rotDims.width, approxEquals(baseDims.width));
          expect(rotDims.height, approxEquals(baseDims.height));
        },
      );

      testWidgets(
        'rotate=270 swaps width/height relative to the unrotated output',
        (_) async {
          final src = await loadAssetBytes('img/img.jpg');
          final base = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 800,
            minHeight: 800,
            quality: 85,
          );
          final rotated = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 800,
            minHeight: 800,
            quality: 85,
            rotate: 270,
          );
          final baseDims = await decodeDimensions(base);
          final rotDims = await decodeDimensions(rotated);
          expect(rotDims.width, approxEquals(baseDims.height));
          expect(rotDims.height, approxEquals(baseDims.width));
        },
      );
    },
  );

  group(
    'EXIF orientation',
    () {
      // have-exif.jpg stores pixels as 3264x2448 (landscape) but sets EXIF
      // Orientation=6 (rotate 90° CW → intended portrait 2448x3264). The
      // iOS pipeline applies orientation implicitly (via UIImage's
      // imageOrientation), so the compressed output must be portrait. This
      // locks in the observed behavior — a regression that silently drops
      // orientation would produce landscape output and fail this test.
      //
      // Note: the `autoCorrectionAngle` argument itself is a no-op in the
      // current native code (arg[5] is not read by the Objective-C
      // handlers), so this test does not vary it — orientation handling
      // is a property of the decode path, not that flag.
      testWidgets('portrait EXIF orientation is applied to output', (_) async {
        final src = await loadAssetBytes('img/have-exif.jpg');
        final result = await FlutterImageCompress.compressWithList(
          src,
          minWidth: 600,
          minHeight: 600,
          quality: 85,
        );
        final dims = await decodeDimensions(result);
        expect(dims.height, greaterThan(dims.width),
            reason:
                'output should be portrait (h>w) because source EXIF Orientation=6',);
      });
    },
    // macOS uses a different decode path (NSBitmapImageRep) which does not
    // apply EXIF orientation implicitly. Gate this baseline invariant to
    // iOS rather than paper over the platform gap.
    skip: !Platform.isIOS,
  );

  group('transparency (PNG)', () {
    testWidgets(
      'transparent PNG retains alpha channel through compression',
      (_) async {
        final src = await loadAssetBytes('img/transparent-background.png');
        // Confirm the source really has transparent pixels somewhere —
        // otherwise the plugin's "preserved alpha" would be meaningless.
        expect(await imageHasAlpha(src), isTrue,
            reason: 'source PNG has no alpha < 255 anywhere — asset issue',);

        final result = await FlutterImageCompress.compressWithList(
          src,
          // Source is 320x284 — pick bounds <= source to avoid the no-scale
          // pass-through path masking a real regression.
          minWidth: 200,
          minHeight: 200,
          format: CompressFormat.png,
        );
        expectValidCompressed(
          bytes: result,
          expected: DetectedFormat.png,
          description: 'transparent PNG',
        );

        expect(await imageHasAlpha(result), isTrue,
            reason:
                'output PNG has no pixel with alpha<255 — alpha channel was dropped',);
      },
    );
  });

  group('format interop', () {
    testWidgets(
      'WebP asset can be decoded and re-encoded to JPEG',
      (_) async {
        final result = await FlutterImageCompress.compressAssetImage(
          'img/icon.webp',
          minWidth: 400,
          minHeight: 400,
          quality: 90,
        );
        expect(result, isNotNull,
            reason: 'compressAssetImage for WebP source returned null',);
        final bytes = Uint8List.fromList(result!);
        expectValidCompressed(
          bytes: bytes,
          expected: DetectedFormat.jpeg,
          description: 'WebP -> JPEG',
        );
        final dims = await decodeDimensions(bytes);
        expect(dims.width, greaterThanOrEqualTo(400));
        expect(dims.height, greaterThanOrEqualTo(400));
      },
      // WebP decode requires SDWebImageWebPCoder, which only ships in the
      // common (iOS/Android) package.
      skip: !Platform.isIOS,
    );
  });

  group(
    'keepExif',
    () {
      testWidgets('keepExif=true retains source EXIF keys keepExif=false drops',
          (_) async {
        // Use auto-angle.jpg — a real phone photo with a rich EXIF sub-dict
        // (30+ tags: exposure, focal length, DateTimeOriginal, etc.). Both
        // the plugin's default output and its keepExif=true output share a
        // small set of encoder-injected default keys (PixelXDimension,
        // PixelYDimension, ColorSpace), so a strict-count comparison won't
        // work — assert that keepExif=true retains at least one key that
        // *only* exists because the source carried it.
        final src = await loadAssetBytes('img/auto-angle.jpg');
        final srcKeys = (await readExifKeys(src)).toSet();
        if (srcKeys.isEmpty) {
          markTestSkipped(
              'auto-angle.jpg has no EXIF metadata reachable via test helper',);
          return;
        }

        final kept = await FlutterImageCompress.compressWithList(
          src,
          minWidth: 500,
          minHeight: 500,
          quality: 90,
          keepExif: true,
        );
        final dropped = await FlutterImageCompress.compressWithList(
          src,
          minWidth: 500,
          minHeight: 500,
          quality: 90,
          keepExif: false,
        );
        final keptKeys = (await readExifKeys(kept)).toSet();
        final droppedKeys = (await readExifKeys(dropped)).toSet();

        expect(keptKeys, isNotEmpty,
            reason: 'keepExif=true should retain EXIF keys',);
        // The load-bearing invariant: keepExif=true retains at least one
        // source-provided EXIF key that keepExif=false does not emit.
        final retainedFromSource =
            keptKeys.intersection(srcKeys).difference(droppedKeys);
        expect(retainedFromSource, isNotEmpty,
            reason: 'keepExif=true should retain at least one source EXIF key '
                'that keepExif=false does not emit '
                '(src=$srcKeys kept=$keptKeys dropped=$droppedKeys)',);
      });

      testWidgets(
        'keepExif=true preserves DateTime-family EXIF/TIFF tags — locks in '
        'the direct CGImageSource->CGImageDestination passthrough path so '
        'later refactors that revert to a typed-model middleman (like the '
        'old SYMetadata roundtrip) cannot silently drop these keys',
        (_) async {
          final src = await loadAssetBytes('img/auto-angle.jpg');
          final srcKeys = (await readExifKeys(src)).toSet();
          const canaries = <String>{
            'exif:DateTimeOriginal',
            'exif:DateTimeDigitized',
            'tiff:DateTime',
          };
          final srcCanaries = srcKeys.intersection(canaries);
          if (srcCanaries.isEmpty) {
            markTestSkipped(
                'auto-angle.jpg has no DateTime-family EXIF/TIFF tag '
                '(srcKeys=$srcKeys) — nothing to assert survival for');
            return;
          }

          final kept = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 500,
            minHeight: 500,
            quality: 90,
            keepExif: true,
          );
          final keptKeys = (await readExifKeys(kept)).toSet();
          final survivors = srcCanaries.intersection(keptKeys);
          expect(survivors, srcCanaries,
              reason: 'keepExif=true should preserve every DateTime-family '
                  'EXIF/TIFF tag present in the source '
                  '(src=$srcCanaries survived=$survivors kept=$keptKeys)',);
        },
      );

      testWidgets(
        'keepExif=false does not leak source-identifying EXIF/TIFF tags — '
        'locks in the current re-encode-only path (UIImageJPEGRepresentation '
        'discards source EXIF, so a future refactor that shares an ImageIO '
        'destination between the two branches cannot regress this invariant)',
        (_) async {
          final src = await loadAssetBytes('img/auto-angle.jpg');
          final srcKeys = (await readExifKeys(src)).toSet();
          if (srcKeys.isEmpty) {
            markTestSkipped(
                'auto-angle.jpg has no EXIF/TIFF metadata reachable via helper',);
            return;
          }

          final dropped = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 500,
            minHeight: 500,
            quality: 90,
            keepExif: false,
          );
          final droppedKeys = (await readExifKeys(dropped)).toSet();

          // Anchor tags that identify the source photo (camera model, capture
          // time, lens). Encoder-injected defaults (ColorSpace, PixelXDimension,
          // PixelYDimension) are excluded on purpose — every JPEG carries
          // those regardless of source and asserting on them would fail
          // trivially, not usefully.
          const identifyingKeys = <String>{
            'exif:DateTimeOriginal',
            'exif:DateTimeDigitized',
            'exif:LensMake',
            'exif:LensModel',
            'tiff:DateTime',
            'tiff:Make',
            'tiff:Model',
            'tiff:Software',
          };
          final srcIdentifying = srcKeys.intersection(identifyingKeys);
          if (srcIdentifying.isEmpty) {
            markTestSkipped(
                'auto-angle.jpg carries none of the identifying tags this '
                'test asserts stripping of (srcKeys=$srcKeys)');
            return;
          }
          final leaked = srcIdentifying.intersection(droppedKeys);
          expect(leaked, isEmpty,
              reason:
                  'keepExif=false must not leak source identifying metadata '
                  '(leaked=$leaked droppedKeys=$droppedKeys)',);
        },
      );

      testWidgets(
        'WebP + keepExif=true: does not crash, emits a valid WebP',
        (_) async {
          // Regression for issue #217: iOS crashed on WebP + keepExif=true
          // because SYMetadata's ImageIO-backed rewrite returns nil for
          // containers ImageIO can't author (WebP), and the nil bytes were
          // then handed to FlutterStandardTypedData typedDataWithBytes:.
          final src = await loadAssetBytes('img/auto-angle.jpg');
          final result = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 500,
            minHeight: 500,
            quality: 80,
            format: CompressFormat.webp,
            keepExif: true,
          );
          expectValidCompressed(
            bytes: result,
            expected: DetectedFormat.webp,
            description: 'WebP + keepExif',
          );
        },
        // WebP is iOS/Android only in the common package.
        skip: !Platform.isIOS,
      );

      testWidgets(
        'HEIC + keepExif=true: emits a valid HEIC with a preserved '
        'DateTime-family tag — smoke test that the metadata-rich options '
        'dict does not trip the HEIC destination (macOS ImageIO used to '
        'be silently rejected by metadata sub-dicts before the finalize '
        'return was checked)',
        (_) async {
          final src = await loadAssetBytes('img/auto-angle.jpg');
          final srcKeys = (await readExifKeys(src)).toSet();
          const canaries = <String>{
            'exif:DateTimeOriginal',
            'exif:DateTimeDigitized',
            'tiff:DateTime',
          };
          final srcCanaries = srcKeys.intersection(canaries);

          final result = await FlutterImageCompress.compressWithList(
            src,
            minWidth: 500,
            minHeight: 500,
            quality: 85,
            format: CompressFormat.heic,
            keepExif: true,
          );
          expectValidCompressed(
            bytes: result,
            expected: DetectedFormat.heic,
            description: 'HEIC + keepExif',
          );

          // Only assert metadata survival when the source carries one of
          // the canary tags — some CI base images may strip them.
          if (srcCanaries.isNotEmpty) {
            final keptKeys = (await readExifKeys(result)).toSet();
            final survivors = srcCanaries.intersection(keptKeys);
            expect(survivors, srcCanaries,
                reason: 'HEIC + keepExif=true should preserve DateTime tags '
                    '(src=$srcCanaries survived=$survivors kept=$keptKeys)',);
          }
        },
      );
    },
    // Now that macOS pumps source properties through as nested sub-dicts
    // (matching iOS's direct passthrough), the keepExif invariants run on
    // both platforms. The WebP-inner test stays iOS-only because the
    // macOS package doesn't ship the WebP coder.
    skip: !(Platform.isIOS || Platform.isMacOS),
  );
}
