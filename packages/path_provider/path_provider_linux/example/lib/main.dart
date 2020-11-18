import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  runApp(MyApp());
}

/// Sample app
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tempDirectory = 'Unknown';
  String _downloadsDirectory = 'Unknown';
  String _appSupportDirectory = 'Unknown';
  String _documentsDirectory = 'Unknown';

  @override
  void initState() {
    super.initState();
    initDirectories();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initDirectories() async {
    String tempDirectory;
    String downloadsDirectory;
    String appSupportDirectory;
    String documentsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      tempDirectory = (await getTemporaryDirectory()).path;
    } on PlatformException {
      tempDirectory = 'Failed to get temp directory.';
    }
    try {
      downloadsDirectory = (await getDownloadsDirectory()).path;
    } on PlatformException {
      downloadsDirectory = 'Failed to get downloads directory.';
    }

    try {
      documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    } on PlatformException {
      documentsDirectory = 'Failed to get documents directory.';
    }

    try {
      appSupportDirectory = (await getApplicationSupportDirectory()).path;
    } on PlatformException {
      appSupportDirectory = 'Failed to get documents directory.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _tempDirectory = tempDirectory;
      _downloadsDirectory = downloadsDirectory;
      _appSupportDirectory = appSupportDirectory;
      _documentsDirectory = documentsDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Path Provider Linux example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Temp Directory: $_tempDirectory\n'),
              Text('Documents Directory: $_documentsDirectory\n'),
              Text('Downloads Directory: $_downloadsDirectory\n'),
              Text('Application Support Directory: $_appSupportDirectory\n'),
            ],
          ),
        ),
      ),
    );
  }
}
