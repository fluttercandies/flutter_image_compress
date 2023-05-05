import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data' as typed_data;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../const/resource.dart';

Future<void> runMain() async {
  runApp(const MyApp());
  FlutterImageCompress.showNativeLog = true;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ImageProvider? provider;

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
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressAsset,
                child: Text('Compress asset'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressList,
                child: Text('Compress uint8List'),
              ),
            ),
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

  Future<void> _compressAsset() async {
    final assetName = R.IMG_IMG_JPG;
    _changeImageWithUint8List(
      await FlutterImageCompress.compressAssetImage(assetName),
    );
  }

  Future<void> _compressList() async {
    final bytes = await rootBundle
        .load(R.IMG_IMG_JPG)
        .then((value) => value.buffer.asUint8List());
    _changeImageWithUint8List(
      await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 400,
        minHeight: 200,
      ),
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

class TextButton extends StatelessWidget {
  const TextButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class XFileImageProvider extends ImageProvider<XFileImageProvider> {
  const XFileImageProvider(this.file);

  final XFile file;

  @override
  Future<XFileImageProvider> obtainKey(ImageConfiguration configuration) async {
    return this;
  }

  Future<ui.Codec> _loadAsync(
      XFileImageProvider key, DecoderBufferCallback decode) async {
    final bytes = await file.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  ImageStreamCompleter loadBuffer(
      XFileImageProvider key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Path: ${file.path}');
      },
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final XFileImageProvider typedOther = other;
    return file.path == typedOther.file.path;
  }

  @override
  int get hashCode => file.path.hashCode;

  @override
  String toString() => '$runtimeType("${file.path}",)';
}
