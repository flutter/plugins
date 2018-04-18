// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class FirebaseStorage {
  static const MethodChannel channel =
      const MethodChannel('plugins.flutter.io/firebase_storage');

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
  StorageUploadTask put(File file, [StorageMetadata metadata]) {
    final StorageUploadTask task =
        new StorageUploadTask._(file, _pathComponents.join("/"), metadata);
    task._start();
    return task;
  }

  /// Asynchronously downloads the object at the StorageReference to a list in memory.
  /// A list of the provided max size will be allocated.
  Future<Uint8List> getData(int maxSize) async {
    return await FirebaseStorage.channel.invokeMethod(
      "StorageReference#getData",
      <String, dynamic>{
        'maxSize': maxSize,
        'path': _pathComponents.join("/"),
      },
    );
  }

  Future<dynamic> getDownloadURL() async {
    return await FirebaseStorage.channel
        .invokeMethod("StorageReference#getDownloadUrl", <String, String>{
      'path': _pathComponents.join("/"),
    });
  }

  Future<void> delete() {
    return FirebaseStorage.channel.invokeMethod("StorageReference#delete",
        <String, String>{'path': _pathComponents.join("/")});
  }

  /// Retrieves metadata associated with an object at this [StorageReference].
  Future<StorageMetadata> getMetadata() async {
    return new StorageMetadata._fromMap(await FirebaseStorage._channel
        .invokeMethod("StorageReference#getMetadata", <String, String>{
      'path': _pathComponents.join("/"),
    }));
  }

  String get path => _pathComponents.join('/');
}

/// Metadata for a [StorageReference]. Metadata stores default attributes such as
/// size and content type.
class StorageMetadata {
  StorageMetadata({
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.contentType,
  }) : bucket = null,
       generation = null,
       metadataGeneration = null,
       path = null,
       name = null,
       sizeBytes = null,
       creationTimeMillis = null,
       updatedTimeMillis = null,
       md5Hash = null;

  StorageMetadata._fromMap(Map<String, dynamic> map)
      : bucket = map['bucket'],
        generation = map['generation'],
        metadataGeneration = map['metadataGeneration'],
        path = map['path'],
        name = map['name'],
        sizeBytes=  map['sizeBytes'],
        creationTimeMillis = map['creationTimeMillis'],
        updatedTimeMillis = map['updatedTimeMillis'],
        md5Hash = map['md5Hash'],
        cacheControl = map['cacheControl'],
        contentDisposition = map['contentDisposition'],
        contentLanguage = map['contentLanguage'],
        contentType = map['contentType'],
        contentEncoding = map['contentEncoding'];

  /// The owning Google Cloud Storage bucket for the [StorageReference].
  final String bucket;

  /// A version String indicating what version of the [StorageReference].
  final String generation;

  /// A version String indicating the version of this [StorageMetadata].
  final String metadataGeneration;

  /// The path of the [StorageReference] object.
  final String path;

  /// A simple name of the [StorageReference] object.
  final String name;

  /// The stored Size in bytes of the [StorageReference] object.
  final int sizeBytes;

  /// The time the [StorageReference] was created.
  final num creationTimeMillis;

  /// The time the [StorageReference] was last updated.
  final num updatedTimeMillis;

  /// The MD5Hash of the [StorageReference] object.
  final String md5Hash;

  /// The Cache Control setting of the [StorageReference].
  String cacheControl;

  /// The content disposition of the [StorageReference].
  String contentDisposition;

  /// The content encoding for the [StorageReference].
  String contentEncoding;

  /// The content language for the StorageReference, specified as a 2-letter
  /// lowercase language code defined by ISO 639-1.
  String contentLanguage;

  /// The content type of the [StorageReference].
  String contentType;

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      'bucket': bucket,
      'generation': generation,
      'metadataGeneration': metadataGeneration,
      'path': path,
      'name' : name,
      'sizeBytes': sizeBytes,
      'creationTimeMillis': creationTimeMillis,
      'updatedTimeMillis': updatedTimeMillis,
      'md5Hash': md5Hash,
      'cacheControl': cacheControl,
      'contentDisposition': contentDisposition,
      'contentLanguage': contentLanguage,
      'contentType': contentType,
      'contentEncoding': contentEncoding,
    };
  }
}

class StorageUploadTask {
  StorageUploadTask._(this.file, this.path, [this.metadata]);

  final File file;
  final String path;
  final StorageMetadata metadata;

  Completer<UploadTaskSnapshot> _completer =
      new Completer<UploadTaskSnapshot>();
  Future<UploadTaskSnapshot> get future => _completer.future;


  Future<void> _start() async {
    final String downloadUrl = await FirebaseStorage.channel.invokeMethod(
      "StorageReference#putFile",
      <String, dynamic>{
        'filename': file.absolute.path,
        'path': path,
        'metadata': metadata != null ? metadata.toMap() : null,
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
