// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class FirebaseStorage {
  static const MethodChannel _channel = const MethodChannel('firebase_storage');

  static FirebaseStorage get instance => new FirebaseStorage();

  StorageReference ref() {
    return const StorageReference._(const <String>[]);
  }
}

class StorageReference {
  const StorageReference._(this._pathComponents);
  final List<String> _pathComponents;

  StorageReference child(String path) {
    List<String> childPath = new List<String>.from(_pathComponents)..addAll(path.split("/"));
    return new StorageReference._(childPath);
  }

  StorageUploadTask put(File file) {
    StorageUploadTask task = new StorageUploadTask._(file, _pathComponents.join("/"));
    task._start();
    return task;
  }
}

class StorageUploadTask {
  StorageUploadTask._(this.file, this.path);
  final File file;
  final String path;

  Completer<UploadTaskSnapshot> _completer = new Completer<UploadTaskSnapshot>();
  Future<UploadTaskSnapshot> get future => _completer.future;

  Future<Null> _start() async {
    String downloadUrl = await FirebaseStorage._channel.invokeMethod(
        "StorageReference#putFile",
        <String, String>{
          'filename': file.absolute.path,
          'path': path,
        },
    );
    _completer.complete(new UploadTaskSnapshot(downloadUrl: Uri.parse(downloadUrl)));
  }
}

class UploadTaskSnapshot {
  UploadTaskSnapshot({ this.downloadUrl });
  final Uri downloadUrl;
}
