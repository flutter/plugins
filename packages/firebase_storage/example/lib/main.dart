// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Storage Example',
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

const String kTestString = "Hello world!";

class _MyHomePageState extends State<MyHomePage> {
  String _fileContents;

  Future<Null> _uploadFile() async {
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await new File('${systemTempDir.path}/foo.txt').create();
    file.writeAsString(kTestString);
    assert(await file.readAsString() == kTestString);
    final String rand = "${new Random().nextInt(10000)}";
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("foo$rand.txt");
    final StorageUploadTask uploadTask = ref.put(file);
    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    final http.Response downloadData = await http.get(downloadUrl);
    setState(() {
      _fileContents = downloadData.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Flutter Storage Example'),
      ),
      body: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _fileContents == null
                ? const Text('Press the button to upload a file')
                : new Text(
                    'Success!\n\nFile contents: "$_fileContents"',
                    style: const TextStyle(
                        color: const Color.fromARGB(255, 0, 155, 0)),
                  )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _uploadFile,
        tooltip: 'Upload',
        child: const Icon(Icons.file_upload),
      ),
    );
  }
}
