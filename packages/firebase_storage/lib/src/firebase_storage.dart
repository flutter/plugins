// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

/// FirebaseStorage is a service that supports uploading and downloading large
/// objects to Google Cloud Storage.
class FirebaseStorage {
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
  FirebaseStorage({this.app, this.storageBucket}) {
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      _methodStreamController.add(call);
    });
    _initialized = true;
  }

  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_storage');

  static bool _initialized = false;

  static FirebaseStorage _instance = FirebaseStorage();

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

  /// Used to dispatch method calls
  static final StreamController<MethodCall> _methodStreamController =
      StreamController<MethodCall>.broadcast(); // ignore: close_sinks
  Stream<MethodCall> get _methodStream => _methodStreamController.stream;

  /// Creates a new [StorageReference] initialized at the root
  /// Firebase Storage location.
  StorageReference ref() => StorageReference._(const <String>[], this);

  Future<int> getMaxDownloadRetryTimeMillis() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return await channel.invokeMethod(
        "FirebaseStorage#getMaxDownloadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
    });
  }

  Future<int> getMaxUploadRetryTimeMillis() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return await channel.invokeMethod(
        "FirebaseStorage#getMaxUploadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
    });
  }

  Future<int> getMaxOperationRetryTimeMillis() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return await channel.invokeMethod(
        "FirebaseStorage#getMaxOperationRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
    });
  }

  Future<void> setMaxDownloadRetryTimeMillis(int time) {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return channel.invokeMethod(
        "FirebaseStorage#setMaxDownloadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
      'time': time,
    });
  }

  Future<void> setMaxUploadRetryTimeMillis(int time) {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return channel.invokeMethod(
        "FirebaseStorage#setMaxUploadRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
      'time': time,
    });
  }

  Future<void> setMaxOperationRetryTimeMillis(int time) {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return channel.invokeMethod(
        "FirebaseStorage#setMaxOperationRetryTime", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
      'time': time,
    });
  }

  /// Creates a [StorageReference] given a gs:// or // URL pointing to a Firebase
  /// Storage location.
  Future<StorageReference> getReferenceFromUrl(String fullUrl) async {
    final String path = await channel.invokeMethod(
        "FirebaseStorage#getReferenceFromUrl", <String, dynamic>{
      'app': app?.name,
      'bucket': storageBucket,
      'fullUrl': fullUrl
    });
    if (path != null) {
      return ref().child(path);
    } else {
      return null;
    }
  }
}

/// TODO: Move into own file and build out progress functionality
class StorageFileDownloadTask {
  StorageFileDownloadTask._(this._firebaseStorage, this._path, this._file);

  final FirebaseStorage _firebaseStorage;
  final String _path;
  final File _file;

  Future<void> _start() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
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
        .complete(FileDownloadTaskSnapshot(totalByteCount: totalByteCount));
  }

  Completer<FileDownloadTaskSnapshot> _completer =
      Completer<FileDownloadTaskSnapshot>();
  Future<FileDownloadTaskSnapshot> get future => _completer.future;
}

class FileDownloadTaskSnapshot {
  FileDownloadTaskSnapshot({this.totalByteCount});
  final int totalByteCount;
}
