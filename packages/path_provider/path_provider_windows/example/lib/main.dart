// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
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

    try {
      tempDirectory = (await getTemporaryDirectory()).path;
    } catch (exception) {
      tempDirectory = 'Failed to get temp directory: $exception';
    }
    try {
      downloadsDirectory = (await getDownloadsDirectory()).path;
    } catch (exception) {
      downloadsDirectory = 'Failed to get downloads directory: $exception';
    }

    try {
      documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    } catch (exception) {
      documentsDirectory = 'Failed to get documents directory: $exception';
    }

    try {
      appSupportDirectory = (await getApplicationSupportDirectory()).path;
    } catch (exception) {
      appSupportDirectory = 'Failed to get app support directory: $exception';
    }

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
          title: const Text('Path Provider example app'),
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
