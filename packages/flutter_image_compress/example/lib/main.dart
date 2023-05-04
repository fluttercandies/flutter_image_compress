import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data' as typed_data;
import 'dart:ui' as ui;

import 'button.dart';
import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'const/resource.dart';
import 'time_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  Future<void> compress() async {
    final img = AssetImage('img/img.jpg');
    print('pre compress');
    final config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final beforeCompress = data.lengthInBytes;
    print('beforeCompress = $beforeCompress');
    final result = await FlutterImageCompress.compressWithList(
      data.buffer.asUint8List(),
    );
    print('after = ${result.length}');
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  void _testCompressFile() async {
    final img = AssetImage('img/img.jpg');
    print('pre compress');
    final config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final dir = await path_provider.getTemporaryDirectory();
    final File file = createFile('${dir.absolute.path}/test.png');
    file.writeAsBytesSync(data.buffer.asUint8List());

    final result = await testCompressFile(file);
    if (result == null) return;

    safeSetState(() {
      provider = MemoryImage(result);
    });
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<String> getExampleFilePath() async {
    final img = AssetImage('img/img.jpg');
    print('pre compress');
    final config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final dir = await path_provider.getTemporaryDirectory();
    final File file = createFile('${dir.absolute.path}/test.png');
    file.createSync(recursive: true);
    file.writeAsBytesSync(data.buffer.asUint8List());
    return file.absolute.path;
  }

  void getFileImage() async {
    final img = AssetImage('img/img.jpg');
    print('pre compress');
    final config = ImageConfiguration();
    final AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    final dir = await path_provider.getTemporaryDirectory();
    final File file = createFile('${dir.absolute.path}/test.png');
    file.writeAsBytesSync(data.buffer.asUint8List());
    final targetPath = dir.absolute.path + '/temp.jpg';
    final imgFile = await testCompressAndGetFile(file, targetPath);
    if (imgFile == null) {
      return;
    }
    safeSetState(() {
      provider = XFileImageProvider(imgFile);
    });
  }

  Future<typed_data.Uint8List?> testCompressFile(File file) async {
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

    if (result == null) return null;

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
    if (list == null) return;
    safeSetState(() {
      provider = MemoryImage(typed_data.Uint8List.fromList(list));
    });
  }

  Future compressListExample() async {
    final data = await rootBundle.load('img/img.jpg');
    final memory = await testComporessList(data.buffer.asUint8List());
    safeSetState(() {
      provider = MemoryImage(memory);
    });
  }

  Future<typed_data.Uint8List> testComporessList(
    typed_data.Uint8List list,
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

  void _compressAssetAndAutoRotate() async {
    final result = await FlutterImageCompress.compressAssetImage(
      R.IMG_AUTO_ANGLE_JPG,
      minWidth: 1000,
      quality: 95,
      // autoCorrectionAngle: false,
    );
    if (result == null) return;
    safeSetState(() {
      provider = MemoryImage(typed_data.Uint8List.fromList(result));
    });
  }

  void _compressPngImage() async {
    final result = await FlutterImageCompress.compressAssetImage(
      R.IMG_HEADER_PNG,
      minWidth: 300,
      minHeight: 500,
    );
    if (result == null) return;
    safeSetState(() {
      provider = MemoryImage(typed_data.Uint8List.fromList(result));
    });
  }

  void _compressTransPNG() async {
    final bytes = await getAssetImageUint8List(
      R.IMG_TRANSPARENT_BACKGROUND_PNG,
    );
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 100,
      minWidth: 100,
      format: CompressFormat.png,
    );
    final u8list = typed_data.Uint8List.fromList(result);
    safeSetState(() {
      provider = MemoryImage(u8list);
    });
  }

  void _restoreTransPNG() async {
    setState(() {
      provider = AssetImage(R.IMG_TRANSPARENT_BACKGROUND_PNG);
    });
  }

  void _compressImageAndKeepExif() async {
    final result = await FlutterImageCompress.compressAssetImage(
      R.IMG_AUTO_ANGLE_JPG,
      minWidth: 500,
      minHeight: 600,
      // autoCorrectionAngle: false,
      keepExif: true,
    );
    if (result == null) return;
    safeSetState(() {
      provider = MemoryImage(typed_data.Uint8List.fromList(result));
    });
  }

  void _compressHeicExample() async {
    print('start compress');
    final logger = TimeLogger();
    logger.startRecorder();
    final tmpDir = (await getTemporaryDirectory()).path;
    final target = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.heic';
    final srcPath = await getExampleFilePath();
    final result = await FlutterImageCompress.compressAndGetFile(
      srcPath,
      target,
      format: CompressFormat.heic,
      quality: 90,
    );
    if (result == null) return;

    print('Compress heic success.');
    logger.logTime();
    print('src, path = $srcPath length = ${File(srcPath).lengthSync()}');

    print(
      'Compress heic result path: ${result.path}, '
      'size: ${await result.length()}',
    );
  }

  void _compressAndroidWebpExample() async {
    // Android compress very nice, but the iOS encode UIImage to webp is slow.
    final logger = TimeLogger();
    logger.startRecorder();
    print('start compress webp');
    final quality = 90;
    final tmpDir = (await getTemporaryDirectory()).path;
    final target =
        '$tmpDir/${DateTime.now().millisecondsSinceEpoch}-$quality.webp';
    final srcPath = await getExampleFilePath();
    final result = await FlutterImageCompress.compressAndGetFile(
      srcPath,
      target,
      format: CompressFormat.webp,
      minHeight: 800,
      minWidth: 800,
      quality: quality,
    );
    if (result == null) return;
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

  void _compressFromWebPImage() async {
    // Converting webp to jpeg
    final result = await FlutterImageCompress.compressAssetImage(
      R.IMG_ICON_WEBP,
    );
    if (result == null) return;
    // Show result image
    safeSetState(() {
      provider = MemoryImage(typed_data.Uint8List.fromList(result));
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
                    image: provider ?? AssetImage('img/img.jpg'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('CompressFile and rotate 180'),
                onPressed: _testCompressFile,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('CompressAndGetFile and rotate 90'),
                onPressed: getFileImage,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('CompressAsset and rotate 135'),
                onPressed: () => testCompressAsset('img/img.jpg'),
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('CompressList and rotate 270'),
                onPressed: compressListExample,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('test compress auto angle'),
                onPressed: _compressAssetAndAutoRotate,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('Test png '),
                onPressed: _compressPngImage,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('Format transparent PNG'),
                onPressed: _compressTransPNG,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('Restore transparent PNG'),
                onPressed: _restoreTransPNG,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('Keep exif image'),
                onPressed: _compressImageAndKeepExif,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('Convert to heic format and print the file url'),
                onPressed: _compressHeicExample,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('Convert to webp format, Just support android'),
                onPressed: _compressAndroidWebpExample,
              ),
            ),
            SliverToBoxAdapter(
              child: TextButton(
                child: Text('Convert from webp format'),
                onPressed: _compressFromWebPImage,
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
