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
    return new StorageReference._(const <String>[], this);
  }
}

class StorageReference {
  final FirebaseStorage _firebaseStorage;
  const StorageReference._(this._pathComponents, this._firebaseStorage);
  final List<String> _pathComponents;

  /// Returns a new instance of [StorageReference] pointing to a child
  /// location of the current reference.
  StorageReference child(String path) {
    final List<String> childPath = new List<String>.from(_pathComponents)
      ..addAll(path.split("/"));
    return new StorageReference._(childPath, _firebaseStorage);
  }

  /// Returns a new instance of [StorageReference] pointing to the parent
  /// location or null if this instance references the root location.
  StorageReference getParent() {
    if (_pathComponents.isEmpty ||
        _pathComponents.every((String e) => e.isEmpty)) {
      return null;
    }

    final List<String> parentPath = new List<String>.from(_pathComponents);
    // Trim for trailing empty path components that can
    // come from trailing slashes in the path.
    while (parentPath.last.isEmpty) {
      parentPath.removeLast();
    }
    parentPath.removeLast();

    return new StorageReference._(parentPath, _firebaseStorage);
  }

  /// Returns a new instance of [StorageReference] pointing to the root location.
  StorageReference getRoot() {
    return new StorageReference._(<String>[], _firebaseStorage);
  }

  /// Returns the [FirebaseStorage] service which created this reference.
  FirebaseStorage getStorage() {
    return _firebaseStorage;
  }

  /// This method is deprecated. Please use [putFile] instead.
  ///
  /// Asynchronously uploads a file to the currently specified
  /// [StorageReference], with an optional [metadata].
  @deprecated
  StorageUploadTask put(File file, [StorageMetadata metadata]) {
    return putFile(file, metadata);
  }

  /// Asynchronously uploads a file to the currently specified
  /// [StorageReference], with an optional [metadata].
  StorageUploadTask putFile(File file, [StorageMetadata metadata]) {
    final StorageFileUploadTask task =
        new StorageFileUploadTask._(file, _pathComponents.join("/"), metadata);
    task._start();
    return task;
  }

  /// Asynchronously uploads byte data to the currently specified
  /// [StorageReference], with an optional [metadata].
  StorageUploadTask putData(Uint8List data, [StorageMetadata metadata]) {
    final StorageUploadTask task =
        new StorageDataUploadTask._(data, _pathComponents.join("/"), metadata);
    task._start();
    return task;
  }

  /// Returns the Google Cloud Storage bucket that holds this object.
  Future<String> getBucket() async {
    return await FirebaseStorage.channel
        .invokeMethod("StorageReference#getBucket", <String, String>{
      'path': _pathComponents.join("/"),
    });
  }

  /// Returns the full path to this object, not including the Google Cloud
  /// Storage bucket.
  Future<String> getPath() async {
    return await FirebaseStorage.channel
        .invokeMethod("StorageReference#getPath", <String, String>{
      'path': _pathComponents.join("/"),
    });
  }

  /// Returns the short name of this object.
  Future<String> getName() async {
    return await FirebaseStorage.channel
        .invokeMethod("StorageReference#getName", <String, String>{
      'path': _pathComponents.join("/"),
    });
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

  /// Asynchronously downloads the object at this [StorageReference] to a
  /// specified system file.
  StorageFileDownloadTask writeToFile(File file) {
    final StorageFileDownloadTask task =
        new StorageFileDownloadTask._(_pathComponents.join("/"), file);
    task._start();
    return task;
  }

  /// Asynchronously retrieves a long lived download URL with a revokable token.
  /// This can be used to share the file with others, but can be revoked by a
  /// developer in the Firebase Console if desired.
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
    return new StorageMetadata._fromMap(await FirebaseStorage.channel
        .invokeMethod("StorageReference#getMetadata", <String, String>{
      'path': _pathComponents.join("/"),
    }));
  }

  /// Updates the metadata associated with this [StorageReference].
  ///
  /// Returns a [Future] that will complete to the updated [StorageMetadata].
  ///
  /// This method ignores fields of [metadata] that cannot be set by the public
  /// [StorageMetadata] constructor. Writable metadata properties can be deleted
  /// by passing the empty string.
  Future<StorageMetadata> updateMetadata(StorageMetadata metadata) async {
    return new StorageMetadata._fromMap(await FirebaseStorage.channel
        .invokeMethod("StorageReference#updateMetadata", <String, dynamic>{
      'path': _pathComponents.join("/"),
      'metadata': metadata == null ? null : _buildMetadataUploadMap(metadata),
    }));
  }

  String get path => _pathComponents.join('/');
}

/// Metadata for a [StorageReference]. Metadata stores default attributes such as
/// size and content type.
class StorageMetadata {
  const StorageMetadata({
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.contentType,
  })  : bucket = null,
        generation = null,
        metadataGeneration = null,
        path = null,
        name = null,
        sizeBytes = null,
        creationTimeMillis = null,
        updatedTimeMillis = null,
        md5Hash = null;

  StorageMetadata._fromMap(Map<dynamic, dynamic> map)
      : bucket = map['bucket'],
        generation = map['generation'],
        metadataGeneration = map['metadataGeneration'],
        path = map['path'],
        name = map['name'],
        sizeBytes = map['sizeBytes'],
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

  /// The time the [StorageReference] was created in milliseconds since the epoch.
  final int creationTimeMillis;

  /// The time the [StorageReference] was last updated in milliseconds since the epoch.
  final int updatedTimeMillis;

  /// The MD5Hash of the [StorageReference] object.
  final String md5Hash;

  /// The Cache Control setting of the [StorageReference].
  final String cacheControl;

  /// The content disposition of the [StorageReference].
  final String contentDisposition;

  /// The content encoding for the [StorageReference].
  final String contentEncoding;

  /// The content language for the StorageReference, specified as a 2-letter
  /// lowercase language code defined by ISO 639-1.
  final String contentLanguage;

  /// The content type (MIME type) of the [StorageReference].
  final String contentType;
}

class StorageFileDownloadTask {
  final String _path;
  final File _file;

  StorageFileDownloadTask._(this._path, this._file);

  Future<void> _start() async {
    final int totalByteCount = await FirebaseStorage.channel.invokeMethod(
      "StorageReference#writeToFile",
      <String, dynamic>{
        'filePath': _file.absolute.path,
        'path': _path,
      },
    );
    _completer
        .complete(new FileDownloadTaskSnapshot(totalByteCount: totalByteCount));
  }

  Completer<FileDownloadTaskSnapshot> _completer =
      new Completer<FileDownloadTaskSnapshot>();
  Future<FileDownloadTaskSnapshot> get future => _completer.future;
}

abstract class StorageUploadTask {
  final String _path;
  final StorageMetadata _metadata;

  StorageUploadTask._(this._path, this._metadata);
  Future<void> _start();

  Completer<UploadTaskSnapshot> _completer =
      new Completer<UploadTaskSnapshot>();
  Future<UploadTaskSnapshot> get future => _completer.future;
}

class StorageFileUploadTask extends StorageUploadTask {
  final File _file;
  StorageFileUploadTask._(this._file, String path, StorageMetadata metadata)
      : super._(path, metadata);

  @override
  Future<void> _start() async {
    final String downloadUrl = await FirebaseStorage.channel.invokeMethod(
      'StorageReference#putFile',
      <String, dynamic>{
        'filename': _file.absolute.path,
        'path': _path,
        'metadata':
            _metadata == null ? null : _buildMetadataUploadMap(_metadata),
      },
    );
    _completer
        .complete(new UploadTaskSnapshot(downloadUrl: Uri.parse(downloadUrl)));
  }
}

class StorageDataUploadTask extends StorageUploadTask {
  final Uint8List _bytes;
  StorageDataUploadTask._(this._bytes, String path, StorageMetadata metadata)
      : super._(path, metadata);

  @override
  Future<void> _start() async {
    final String downloadUrl = await FirebaseStorage.channel.invokeMethod(
      'StorageReference#putData',
      <String, dynamic>{
        'data': _bytes,
        'path': _path,
        'metadata':
            _metadata == null ? null : _buildMetadataUploadMap(_metadata),
      },
    );
    _completer
        .complete(new UploadTaskSnapshot(downloadUrl: Uri.parse(downloadUrl)));
  }
}

Map<String, dynamic> _buildMetadataUploadMap(StorageMetadata metadata) {
  return <String, dynamic>{
    'cacheControl': metadata.cacheControl,
    'contentDisposition': metadata.contentDisposition,
    'contentLanguage': metadata.contentLanguage,
    'contentType': metadata.contentType,
    'contentEncoding': metadata.contentEncoding,
  };
}

class UploadTaskSnapshot {
  UploadTaskSnapshot({this.downloadUrl});
  final Uri downloadUrl;
}

class FileDownloadTaskSnapshot {
  FileDownloadTaskSnapshot({this.totalByteCount});
  final int totalByteCount;
}
