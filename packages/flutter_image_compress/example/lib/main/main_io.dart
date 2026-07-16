// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../button.dart';
import '../const/assets.g.dart';
import '../time_logger.dart';

Future<void> runMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  FlutterImageCompress.showNativeLog = true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ImageProvider? provider;

  Future<Directory> getTemporaryDirectory() async {
    final dir = await path_provider.getTemporaryDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<void> compress() async {
    const img = AssetImage('img/img.jpg');
    print('pre compress');
    const config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final beforeCompress = data.lengthInBytes;
    print('beforeCompress = $beforeCompress');
    final result = await FlutterImageCompress.compressWithList(
      data.buffer.asUint8List(),
    );
    print('after = ${result.length}');
  }

  Future<void> _testCompressFile() async {
    const img = AssetImage(Assets.img_img_jpg);
    print('pre compress');
    const config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final dir = await getTemporaryDirectory();
    final file = createFile(p.join(dir.absolute.path, 'test.png'));
    file.writeAsBytesSync(data.buffer.asUint8List());

    final result = await testCompressFile(file);
    if (result == null) {
      return;
    }

    safeSetState(() {
      provider = MemoryImage(result);
    });
  }

  Future<String> getExampleFilePath() async {
    const img = AssetImage('img/img.jpg');
    print('pre compress');
    const config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final dir = await getTemporaryDirectory();
    final File file = createFile(p.join(dir.absolute.path, 'test.png'));
    file.createSync(recursive: true);
    file.writeAsBytesSync(data.buffer.asUint8List());
    return file.absolute.path;
  }

  Future<void> getFileImage() async {
    const img = AssetImage('img/img.jpg');
    print('pre compress');
    const config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final dir = await getTemporaryDirectory();
    final File file = createFile(p.join(dir.absolute.path, 'test.png'));
    file.writeAsBytesSync(data.buffer.asUint8List());
    final targetPath = p.join(dir.absolute.path, 'temp.jpg');
    final imgFile = await testCompressAndGetFile(file, targetPath);
    if (imgFile == null) {
      return;
    }
    safeSetState(() {
      provider = XFileImageProvider(imgFile);
    });
  }

  Future<Uint8List?> testCompressFile(File file) async {
    print('testCompressFile');
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
      rotate: 180,
    );
    print(file.lengthSync());
    print(result?.length);
    return result;
  }

  Future<XFile?> testCompressAndGetFile(File file, String targetPath) async {
    print('testCompressAndGetFile');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
      rotate: 90,
    );

    if (result == null) {
      return null;
    }

    final bytes = await result.readAsBytes();

    print(
      'The src file size: ${file.lengthSync()}, '
      'the result bytes length: ${bytes.length}',
    );
    return result;
  }

  Future testCompressAsset(String assetName) async {
    print('testCompressAsset');
    final list = await FlutterImageCompress.compressAssetImage(
      assetName,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
      rotate: 135,
    );
    if (list == null) {
      return;
    }
    safeSetState(() {
      provider = MemoryImage(Uint8List.fromList(list));
    });
  }

  Future compressListExample() async {
    final data = await rootBundle.load('img/img.jpg');
    final memory = await testComporessList(data.buffer.asUint8List());
    safeSetState(() {
      provider = MemoryImage(memory);
    });
  }

  Future<Uint8List> testComporessList(
    Uint8List list,
  ) async {
    final result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1080,
      minWidth: 1080,
      quality: 96,
      rotate: 270,
      format: CompressFormat.webp,
    );
    print(list.length);
    print(result.length);
    return result;
  }

  Future<void> writeToFile(List<int> list, String filePath) {
    return File(filePath).writeAsBytes(list, flush: true);
  }

  Future<void> _compressAssetAndAutoRotate() async {
    final result = await FlutterImageCompress.compressAssetImage(
      Assets.img_auto_angle_jpg,
      minWidth: 1000,
      quality: 95,
      // autoCorrectionAngle: false,
    );
    if (result == null) {
      return;
    }
    safeSetState(() {
      provider = MemoryImage(Uint8List.fromList(result));
    });
  }

  Future<void> _compressPngImage() async {
    final result = await FlutterImageCompress.compressAssetImage(
      Assets.img_header_png,
      minWidth: 300,
      minHeight: 500,
    );
    if (result == null) {
      return;
    }
    safeSetState(() {
      provider = MemoryImage(Uint8List.fromList(result));
    });
  }

  Future<void> _compressTransPNG() async {
    final bytes = await getAssetImageUint8List(
      Assets.img_transparent_background_png,
    );
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 100,
      minWidth: 100,
      format: CompressFormat.png,
    );
    final u8list = Uint8List.fromList(result);
    safeSetState(() {
      provider = MemoryImage(u8list);
    });
  }

  void _restoreTransPNG() {
    safeSetState(() {
      provider = const AssetImage(Assets.img_transparent_background_png);
    });
  }

  Future<void> _compressImageAndKeepExif() async {
    final result = await FlutterImageCompress.compressAssetImage(
      Assets.img_auto_angle_jpg,
      minWidth: 500,
      minHeight: 600,
      // autoCorrectionAngle: false,
      keepExif: true,
    );
    if (result == null) {
      return;
    }
    safeSetState(() {
      provider = MemoryImage(Uint8List.fromList(result));
    });
  }

  /// The example for compressing heic format.
  ///
  /// Convert jpeg to heic format, and then convert heic to jpg format.
  ///
  /// Show the file path and size in the console.
  Future<void> _compressHeicExample() async {
    print('start compress');
    final logger = TimeLogger();
    logger.startRecorder();
    final tempDir = await getTemporaryDirectory();
    if (!tempDir.existsSync()) {
      tempDir.createSync(recursive: true);
    }
    final tempPath = tempDir.absolute.path;
    final target =
        p.join(tempPath, '${DateTime.now().millisecondsSinceEpoch}.heic');
    final srcPath = await getExampleFilePath();
    final result = await FlutterImageCompress.compressAndGetFile(
      srcPath,
      target,
      format: CompressFormat.heic,
      quality: 90,
    );
    if (result == null) {
      return;
    }

    print('Compress heic success.');
    logger.logTime();
    print('src, path = $srcPath length = ${File(srcPath).lengthSync()}');

    print(
      'Compress heic result path: ${result.path}, '
      'size: ${await result.length()}',
    );

    // Convert heic to jpg
    final jpgPath = p.join(
      tempPath,
      'heic-to-jpg-${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final jpgResult = await FlutterImageCompress.compressAndGetFile(
      result.path,
      jpgPath,
      format: CompressFormat.jpeg,
      quality: 90,
    );
    if (jpgResult == null) {
      print('Convert heic to jpg failed.');
    } else {
      print(
        'Convert heic to jpg success. '
        'Jpg path: ${jpgResult.path}, '
        'size: ${await jpgResult.length()}',
      );
    }
  }

  Future<void> _compressAndroidWebpExample() async {
    // Android compress very nice, but the iOS encode UIImage to webp is slow.
    final logger = TimeLogger();
    logger.startRecorder();
    print('start compress webp');
    const quality = 90;
    final tmpDir = (await getTemporaryDirectory()).path;
    final target = p.join(
      tmpDir,
      '${DateTime.now().millisecondsSinceEpoch}-$quality.webp',
    );
    final srcPath = await getExampleFilePath();
    final result = await FlutterImageCompress.compressAndGetFile(
      srcPath,
      target,
      format: CompressFormat.webp,
      minHeight: 800,
      minWidth: 800,
      quality: quality,
    );
    if (result == null) {
      return;
    }
    print('Compress webp success.');
    logger.logTime();
    print('src, path = $srcPath length = ${File(srcPath).lengthSync()}');
    print(
      'Compress webp result path: ${result.path}, '
      'size: ${await result.length()}',
    );
    safeSetState(() {
      provider = XFileImageProvider(result);
    });
  }

  Future<void> _compressFromWebPImage() async {
    // Converting webp to jpeg
    final result = await FlutterImageCompress.compressAssetImage(
      Assets.img_icon_webp,
    );
    if (result == null) {
      return;
    }
    // Show result image
    safeSetState(() {
      provider = MemoryImage(Uint8List.fromList(result));
    });
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
                    image: provider ?? const AssetImage('img/img.jpg'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _testCompressFile,
                child: const Text('CompressFile and rotate 180'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: getFileImage,
                child: const Text('CompressAndGetFile and rotate 90'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: const Text('CompressAsset and rotate 135'),
                onPressed: () => testCompressAsset('img/img.jpg'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: compressListExample,
                child: const Text('CompressList and rotate 270'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressAssetAndAutoRotate,
                child: const Text('test compress auto angle'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressPngImage,
                child: const Text('Test png '),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressTransPNG,
                child: const Text('Format transparent PNG'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _restoreTransPNG,
                child: const Text('Restore transparent PNG'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressImageAndKeepExif,
                child: const Text('Keep exif image'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressHeicExample,
                child:
                    const Text('Convert to heic format and print the file url'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressAndroidWebpExample,
                child: const Text(
                  'Convert to webp format with 90% quality (Android only)',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                onPressed: _compressFromWebPImage,
                child: const Text('Convert from webp format'),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => provider = null),
          tooltip: 'Show default asset',
          child: const Icon(Icons.settings_backup_restore),
        ),
      ),
    );
  }
}

Future<Uint8List> getAssetImageUint8List(String key) async {
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

class XFileImageProvider extends ImageProvider<XFileImageProvider> {
  const XFileImageProvider(this.file);

  final XFile file;

  @override
  Future<XFileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  Future<ui.Codec> _loadAsync(
    XFileImageProvider key,
    DecoderBufferCallback decode,
  ) async {
    final bytes = await file.readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  ImageStreamCompleter loadBuffer(
    XFileImageProvider key,
    DecoderBufferCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Path: ${file.path}');
      },
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is XFileImageProvider && file.path == other.file.path;
  }

  @override
  int get hashCode => file.path.hashCode;

  @override
  String toString() => '$runtimeType("${file.path}")';
}
