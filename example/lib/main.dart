import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
          child: Image.asset("img/img.jpg"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.computer),
          onPressed: compress,
        ),
      ),
    );
  }
}
