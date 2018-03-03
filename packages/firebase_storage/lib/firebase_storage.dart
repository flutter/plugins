// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
    final List<String> childPath = new List<String>.from(_pathComponents)
      ..addAll(path.split("/"));
    return new StorageReference._(childPath);
  }

  /// Asynchronously uploads a file to the currently specified StorageReference, without additional metadata.
  StorageUploadTask put(File file) {
    final StorageUploadTask task =
        new StorageUploadTask._(file, _pathComponents.join("/"));
    task._start();
    return task;
  }

  /// Asynchronously downloads the object at the StorageReference to a list in memory.
  /// A list of the provided max size will be allocated.
  Future<Uint8List> getData(int maxSize) async {
    return await FirebaseStorage._channel.invokeMethod(
      "StorageReference#getData",
      <String, dynamic>{
        'maxSize': maxSize,
        'path': _pathComponents.join("/"),
      },
    );
  }

  Future<void> delete() {
    return FirebaseStorage._channel.invokeMethod("StorageReference#delete",
        <String, String>{'path': _pathComponents.join("/")});
  }

  String get path => _pathComponents.join('/');
}

class StorageUploadTask {
  StorageUploadTask._(this.file, this.path);
  final File file;
  final String path;

  Completer<UploadTaskSnapshot> _completer =
      new Completer<UploadTaskSnapshot>();
  Future<UploadTaskSnapshot> get future => _completer.future;

  Future<Null> _start() async {
    final String downloadUrl = await FirebaseStorage._channel.invokeMethod(
      "StorageReference#putFile",
      <String, String>{
        'filename': file.absolute.path,
        'path': path,
      },
    );
    _completer
        .complete(new UploadTaskSnapshot(downloadUrl: Uri.parse(downloadUrl)));
  }
}

class UploadTaskSnapshot {
  UploadTaskSnapshot({this.downloadUrl});
  final Uri downloadUrl;
}
