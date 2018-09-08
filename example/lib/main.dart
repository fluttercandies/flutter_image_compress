import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> compress() async {
    var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);

    var beforeCompress = data.lengthInBytes;
    print("beforeCompress = $beforeCompress");

    var result =
        await FlutterImageCompress.compressWithList(data.buffer.asUint8List());

    print("after = ${result?.length ?? 0}");
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: Column(
            children: <Widget>[
              Image.asset("img/img.jpg"),
              FlatButton(
                child: Text('capture'),
                onPressed: _capture,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.computer),
          onPressed: compress,
        ),
      ),
    );
  }

  void _capture() async {
    var img = AssetImage("img/img.jpg");
    print("pre compress");
    var config = new ImageConfiguration();

    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    File file = File("test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
    );
    print(file.lengthSync());
    print(result.length);
  }
}
