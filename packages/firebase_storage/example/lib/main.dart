// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

void main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: new FirebaseOptions(
      googleAppID: Platform.isIOS
          ? '1:159623150305:ios:4a213ef3dbd8997b'
          : '1:159623150305:android:ef48439a0cc0263d',
      gcmSenderID: '159623150305',
      apiKey: 'AIzaSyChk3KEG7QYrs4kQPLP1tjJNxBTbfCAdgg',
      projectID: 'flutter-firebase-plugins',
    ),
  );
  final FirebaseStorage storage = new FirebaseStorage(
      app: app, storageBucket: 'gs://flutter-firebase-plugins.appspot.com');
  runApp(new MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  MyApp({this.storage});
  final FirebaseStorage storage;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Storage Example',
      home: new MyHomePage(storage: storage),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.storage});
  final FirebaseStorage storage;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

const String kTestString = "Hello world!";

class _MyHomePageState extends State<MyHomePage> {
  String _fileContents;
  String _name;
  String _bucket;
  String _path;
  String _tempFileContents;

  Future<Null> _uploadFile() async {
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await new File('${systemTempDir.path}/foo.txt').create();
    file.writeAsString(kTestString);
    assert(await file.readAsString() == kTestString);
    final String rand = "${new Random().nextInt(10000)}";
    final StorageReference ref =
        widget.storage.ref().child('text').child('foo$rand.txt');
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      new StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    final Uri downloadUrl = (await uploadTask.future).downloadUrl;
    final http.Response downloadData = await http.get(downloadUrl);
    final String name = await ref.getName();
    final String bucket = await ref.getBucket();
    final String path = await ref.getPath();
    final File tempFile = new File('${systemTempDir.path}/tmp.txt');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    assert(await tempFile.readAsString() == "");
    final StorageFileDownloadTask task = ref.writeToFile(tempFile);
    final int byteCount = (await task.future).totalByteCount;
    final String tempFileContents = await tempFile.readAsString();
    assert(tempFileContents == kTestString);
    assert(byteCount == kTestString.length);

    setState(() {
      _fileContents = downloadData.body;
      _name = name;
      _path = path;
      _bucket = bucket;
      _tempFileContents = tempFileContents;
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
                ? const Text('Press the button to upload a file \n '
                    'and download its contents to tmp.txt')
                : new Text(
                    'Success!\n Uploaded $_name \n to bucket: $_bucket\n '
                        'at path: $_path \n\nFile contents: "$_fileContents" \n'
                        'Wrote "$_tempFileContents" to tmp.txt',
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
