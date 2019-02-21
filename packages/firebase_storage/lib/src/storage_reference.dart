// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

class StorageReference {
  const StorageReference._(this._pathComponents, this._firebaseStorage);

  final FirebaseStorage _firebaseStorage;
  final List<String> _pathComponents;

  /// Returns a new instance of [StorageReference] pointing to a child
  /// location of the current reference.
  StorageReference child(String path) {
    final List<String> childPath = List<String>.from(_pathComponents)
      ..addAll(path.split("/"));
    return StorageReference._(childPath, _firebaseStorage);
  }

  /// Returns a new instance of [StorageReference] pointing to the parent
  /// location or null if this instance references the root location.
  StorageReference getParent() {
    if (_pathComponents.isEmpty ||
        _pathComponents.every((String e) => e.isEmpty)) {
      return null;
    }

    final List<String> parentPath = List<String>.from(_pathComponents);
    // Trim for trailing empty path components that can
    // come from trailing slashes in the path.
    while (parentPath.last.isEmpty) {
      parentPath.removeLast();
    }
    parentPath.removeLast();

    return StorageReference._(parentPath, _firebaseStorage);
  }

  /// Returns a new instance of [StorageReference] pointing to the root location.
  StorageReference getRoot() {
    return StorageReference._(<String>[], _firebaseStorage);
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
    final _StorageFileUploadTask task =
        _StorageFileUploadTask._(file, _firebaseStorage, this, metadata);
    task._start();
    return task;
  }

  /// Asynchronously uploads byte data to the currently specified
  /// [StorageReference], with an optional [metadata].
  StorageUploadTask putData(Uint8List data, [StorageMetadata metadata]) {
    final StorageUploadTask task =
        _StorageDataUploadTask._(data, _firebaseStorage, this, metadata);
    task._start();
    return task;
  }

  /// Returns the Google Cloud Storage bucket that holds this object.
  Future<String> getBucket() async {
    return await FirebaseStorage.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod("StorageReference#getBucket", <String, String>{
      'app': _firebaseStorage.app?.name,
      'bucket': _firebaseStorage.storageBucket,
      'path': _pathComponents.join("/"),
    });
  }

  /// Returns the full path to this object, not including the Google Cloud
  /// Storage bucket.
  Future<String> getPath() async {
    return await FirebaseStorage.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod("StorageReference#getPath", <String, String>{
      'app': _firebaseStorage.app?.name,
      'bucket': _firebaseStorage.storageBucket,
      'path': _pathComponents.join("/"),
    });
  }

  /// Returns the short name of this object.
  Future<String> getName() async {
    return await FirebaseStorage.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod("StorageReference#getName", <String, String>{
      'app': _firebaseStorage.app?.name,
      'bucket': _firebaseStorage.storageBucket,
      'path': _pathComponents.join("/"),
    });
  }

  /// Asynchronously downloads the object at the StorageReference to a list in memory.
  /// A list of the provided max size will be allocated.
  Future<Uint8List> getData(int maxSize) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return await FirebaseStorage.channel.invokeMethod(
      "StorageReference#getData",
      <String, dynamic>{
        'app': _firebaseStorage.app?.name,
        'bucket': _firebaseStorage.storageBucket,
        'maxSize': maxSize,
        'path': _pathComponents.join("/"),
      },
    );
  }

  /// Asynchronously downloads the object at this [StorageReference] to a
  /// specified system file.
  StorageFileDownloadTask writeToFile(File file) {
    final StorageFileDownloadTask task = StorageFileDownloadTask._(
        _firebaseStorage, _pathComponents.join("/"), file);
    task._start();
    return task;
  }

  /// Asynchronously retrieves a long lived download URL with a revokable token.
  /// This can be used to share the file with others, but can be revoked by a
  /// developer in the Firebase Console if desired.
  Future<dynamic> getDownloadURL() async {
    return await FirebaseStorage.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod("StorageReference#getDownloadUrl", <String, String>{
      'app': _firebaseStorage.app?.name,
      'bucket': _firebaseStorage.storageBucket,
      'path': _pathComponents.join("/"),
    });
  }

  Future<void> delete() {
    return FirebaseStorage.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod("StorageReference#delete", <String, String>{
      'app': _firebaseStorage.app?.name,
      'bucket': _firebaseStorage.storageBucket,
      'path': _pathComponents.join("/")
    });
  }

  /// Retrieves metadata associated with an object at this [StorageReference].
  Future<StorageMetadata> getMetadata() async {
    return StorageMetadata._fromMap(await FirebaseStorage.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod("StorageReference#getMetadata", <String, String>{
      'app': _firebaseStorage.app?.name,
      'bucket': _firebaseStorage.storageBucket,
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
    return StorageMetadata._fromMap(await FirebaseStorage.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod("StorageReference#updateMetadata", <String, dynamic>{
      'app': _firebaseStorage.app?.name,
      'bucket': _firebaseStorage.storageBucket,
      'path': _pathComponents.join("/"),
      'metadata': metadata == null ? null : _buildMetadataUploadMap(metadata),
    }));
  }

  String get path => _pathComponents.join('/');
}
