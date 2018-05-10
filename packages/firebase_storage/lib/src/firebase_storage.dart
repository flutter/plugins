// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

/// FirebaseStorage is a service that supports uploading and downloading large
/// objects to Google Cloud Storage.
class FirebaseStorage {
  static const MethodChannel channel =
      const MethodChannel('plugins.flutter.io/firebase_storage');

  /// Returns the [FirebaseStorage] instance, initialized with a custom
  /// [FirebaseApp] if [app] is specified and a custom Google Cloud Storage
  /// bucket if [storageBucket] is specified. Otherwise the instance will be
  /// initialized with the default [FirebaseApp].
  ///
  /// The [FirebaseStorage] instance is a singleton for fixed [app] and
  /// [storageBucket].
  ///
  /// The [storageBucket] argument is the gs:// url to the custom Firebase
  /// Storage Bucket.
  ///
  /// The [app] argument is the custom [FirebaseApp].
  FirebaseStorage({this.app, this.storageBucket});

  static FirebaseStorage _instance = new FirebaseStorage();

  /// The [FirebaseApp] instance to which this [FirebaseStorage] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  final FirebaseApp app;

  /// The Google Cloud Storage bucket to which this [FirebaseStorage] belongs.
  ///
  /// If null, the storage bucket of the specified [FirebaseApp] is used.
  final String storageBucket;

  /// Returns the [FirebaseStorage] instance, initialized with the default
  /// [FirebaseApp].
  static FirebaseStorage get instance => _instance;

  /// Creates a new [StorageReference] initialized at the root
  /// Firebase Storage location.
  StorageReference ref() => new StorageReference._(const <String>[], this);

  Future<int> getMaxDownloadRetryTimeMillis() async {
    return await channel.invokeMethod(
        "FirebaseStorage#getMaxDownloadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
    });
  }

  Future<int> getMaxUploadRetryTimeMillis() async {
    return await channel.invokeMethod(
        "FirebaseStorage#getMaxUploadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
    });
  }

  Future<int> getMaxOperationRetryTimeMillis() async {
    return await channel.invokeMethod(
        "FirebaseStorage#getMaxOperationRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
    });
  }

  Future<void> setMaxDownloadRetryTimeMillis(int time) {
    return channel.invokeMethod(
        "FirebaseStorage#setMaxDownloadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
      'time': time,
    });
  }

  Future<void> setMaxUploadRetryTimeMillis(int time) {
    return channel.invokeMethod(
        "FirebaseStorage#setMaxUploadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
      'time': time,
    });
  }

  Future<void> setMaxOperationRetryTimeMillis(int time) {
    return channel.invokeMethod(
        "FirebaseStorage#setMaxOperationRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
      'time': time,
    });
  }
}

class StorageFileDownloadTask {
  final FirebaseStorage _firebaseStorage;
  final String _path;
  final File _file;

  StorageFileDownloadTask._(this._firebaseStorage, this._path, this._file);

  Future<void> _start() async {
    final int totalByteCount = await FirebaseStorage.channel.invokeMethod(
      "StorageReference#writeToFile",
      <String, dynamic>{
        'app': _firebaseStorage.app?.name,
        'bucket': _firebaseStorage.storageBucket,
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

class FileDownloadTaskSnapshot {
  FileDownloadTaskSnapshot({this.totalByteCount});
  final int totalByteCount;
}
