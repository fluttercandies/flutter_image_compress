import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data' as typed_data;

import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../button.dart';
import '../const/resource.dart';
import '../time_logger.dart';

Future<void> runMain() async {
  runApp(const MyApp());
  FlutterImageCompress.showNativeLog = true;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

typedef _FutureVoidCallback = FutureOr<Uint8List?> Function();

class _MyAppState extends State<MyApp> {
  final TimeLogger timeLogger = TimeLogger('Compress method time');
  ImageProvider? provider;

  Widget button(_FutureVoidCallback onPressed, String text) {
    return SliverToBoxAdapter(
      child: TextButton(
        onPressed: () async {
          timeLogger.startRecorder();
          final bytes = await onPressed();
          timeLogger.logTime();
          _changeImageWithUint8List(bytes);
        },
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(width: 2)),
                  child: Image(
                    image: provider ?? AssetImage('img/img.jpg'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            button(_compressAsset, 'Compress asset'),
            button(_compressList, 'Compress uint8List'),
            button(_compressPNG, 'Compress PNG'),
            button(_compressHaveExif, 'Compress have exif'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.settings_backup_restore),
          onPressed: () => setState(() => provider = null),
          tooltip: 'Show default asset',
        ),
      ),
    );
  }

  Future<Uint8List?> _compressAsset() {
    final assetName = R.IMG_IMG_JPG;
    return FlutterImageCompress.compressAssetImage(assetName);
  }

  Future<Uint8List?> _compressList() async {
    final bytes = await rootBundle
        .load(R.IMG_IMG_JPG)
        .then((value) => value.buffer.asUint8List());
    return FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 400,
      minHeight: 200,
    );
  }

  Future<Uint8List?> _compressPNG() async {
    final bytes = await rootBundle
        .load(R.IMG_HEADER_PNG)
        .then((value) => value.buffer.asUint8List());
    return FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 400,
      minHeight: 200,
      format: CompressFormat.png,
    );
  }

  Future<Uint8List?> _compressHaveExif() {
    return FlutterImageCompress.compressAssetImage(
      R.IMG_HAVE_EXIF_JPG,
      minWidth: 400,
      minHeight: 200,
      rotate: 180,
    );
  }

  void _changeImageWithUint8List(typed_data.Uint8List? bytes) {
    if (bytes != null) {
      safeSetState(() {
        provider = MemoryImage(bytes);
      });
    }
  }
}

Future<typed_data.Uint8List> getAssetImageUint8List(String key) async {
  final byteData = await rootBundle.load(key);
  return byteData.buffer.asUint8List();
}

double calcScale({
  required double srcWidth,
  required double srcHeight,
  required double minWidth,
  required double minHeight,
}) {
  final scaleW = srcWidth / minWidth;
  final scaleH = srcHeight / minHeight;

  final scale = math.max(1.0, math.min(scaleW, scaleH));

  return scale;
}

extension _StateExtension on State {
  /// [setState] when it's not building, then wait until next frame built.
  FutureOr<void> safeSetState(FutureOr<dynamic> Function() fn) async {
    await fn();
    if (mounted &&
        !context.debugDoingBuild &&
        context.owner?.debugBuilding == false) {
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
    final Completer<void> completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
  }
}
