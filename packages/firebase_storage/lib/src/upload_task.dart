// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

abstract class StorageUploadTask {
  StorageUploadTask._(this._firebaseStorage, this._ref, this._metadata);

  final FirebaseStorage _firebaseStorage;
  final StorageReference _ref;
  final StorageMetadata _metadata;

  Future<dynamic> _platformStart();

  int _handle;

  bool isCanceled = false;
  bool isComplete = false;
  bool isInProgress = true;
  bool isPaused = false;
  bool isSuccessful = false;

  StorageTaskSnapshot lastSnapshot;

  /// Returns a last snapshot when completed
  Completer<StorageTaskSnapshot> _completer = Completer<StorageTaskSnapshot>();
  Future<StorageTaskSnapshot> get onComplete => _completer.future;

  StreamController<StorageTaskEvent> _controller =
      StreamController<StorageTaskEvent>.broadcast();
  Stream<StorageTaskEvent> get events => _controller.stream;

  Future<StorageTaskSnapshot> _start() async {
    _handle = await _platformStart();
    final StorageTaskEvent event = await _firebaseStorage._methodStream
        .where((MethodCall m) {
      return m.method == 'StorageTaskEvent' && m.arguments['handle'] == _handle;
    }).map<StorageTaskEvent>((MethodCall m) {
      final Map<dynamic, dynamic> args = m.arguments;
      final StorageTaskEvent e =
          StorageTaskEvent._(args['type'], _ref, args['snapshot']);
      _changeState(e);
      lastSnapshot = e.snapshot;
      _controller.add(e);
      if (e.type == StorageTaskEventType.success ||
          e.type == StorageTaskEventType.failure) {
        _completer.complete(e.snapshot);
      }
      return e;
    }).firstWhere((StorageTaskEvent e) =>
            e.type == StorageTaskEventType.success ||
            e.type == StorageTaskEventType.failure);
    return event.snapshot;
  }

  void _changeState(StorageTaskEvent event) {
    _resetState();
    print('EVENT ${event.type}');
    switch (event.type) {
      case StorageTaskEventType.progress:
        isInProgress = true;
        break;
      case StorageTaskEventType.resume:
        isInProgress = true;
        break;
      case StorageTaskEventType.pause:
        isPaused = true;
        break;
      case StorageTaskEventType.success:
        isSuccessful = true;
        isComplete = true;
        break;
      case StorageTaskEventType.failure:
        isComplete = true;
        if (event.snapshot.error == StorageError.canceled) {
          isCanceled = true;
        }
        break;
    }
  }

  void _resetState() {
    isCanceled = false;
    isComplete = false;
    isInProgress = false;
    isPaused = false;
    isSuccessful = false;
  }

  /// Pause the upload
  // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
  // https://github.com/flutter/flutter/issues/26431
  // ignore: strong_mode_implicit_dynamic_method
  void pause() => FirebaseStorage.channel.invokeMethod(
        'UploadTask#pause',
        <String, dynamic>{
          'app': _firebaseStorage.app?.name,
          'bucket': _firebaseStorage.storageBucket,
          'handle': _handle,
        },
      );

  /// Resume the upload
  // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
  // https://github.com/flutter/flutter/issues/26431
  // ignore: strong_mode_implicit_dynamic_method
  void resume() => FirebaseStorage.channel.invokeMethod(
        'UploadTask#resume',
        <String, dynamic>{
          'app': _firebaseStorage.app?.name,
          'bucket': _firebaseStorage.storageBucket,
          'handle': _handle,
        },
      );

  /// Cancel the upload
  // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
  // https://github.com/flutter/flutter/issues/26431
  // ignore: strong_mode_implicit_dynamic_method
  void cancel() => FirebaseStorage.channel.invokeMethod(
        'UploadTask#cancel',
        <String, dynamic>{
          'app': _firebaseStorage.app?.name,
          'bucket': _firebaseStorage.storageBucket,
          'handle': _handle,
        },
      );
}

class _StorageFileUploadTask extends StorageUploadTask {
  _StorageFileUploadTask._(this._file, FirebaseStorage firebaseStorage,
      StorageReference ref, StorageMetadata metadata)
      : super._(firebaseStorage, ref, metadata);

  final File _file;

  @override
  Future<dynamic> _platformStart() {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return FirebaseStorage.channel.invokeMethod(
      'StorageReference#putFile',
      <String, dynamic>{
        'app': _firebaseStorage.app?.name,
        'bucket': _firebaseStorage.storageBucket,
        'filename': _file.absolute.path,
        'path': _ref.path,
        'metadata':
            _metadata == null ? null : _buildMetadataUploadMap(_metadata),
      },
    );
  }
}

class _StorageDataUploadTask extends StorageUploadTask {
  _StorageDataUploadTask._(this._bytes, FirebaseStorage firebaseStorage,
      StorageReference ref, StorageMetadata metadata)
      : super._(firebaseStorage, ref, metadata);

  final Uint8List _bytes;

  @override
  Future<dynamic> _platformStart() {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return FirebaseStorage.channel.invokeMethod(
      'StorageReference#putData',
      <String, dynamic>{
        'app': _firebaseStorage.app?.name,
        'bucket': _firebaseStorage.storageBucket,
        'data': _bytes,
        'path': _ref.path,
        'metadata':
            _metadata == null ? null : _buildMetadataUploadMap(_metadata),
      },
    );
  }
}

Map<String, dynamic> _buildMetadataUploadMap(StorageMetadata metadata) {
  return <String, dynamic>{
    'cacheControl': metadata.cacheControl,
    'contentDisposition': metadata.contentDisposition,
    'contentLanguage': metadata.contentLanguage,
    'contentType': metadata.contentType,
    'contentEncoding': metadata.contentEncoding,
    'customMetadata': metadata.customMetadata,
  };
}
