// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_storage;

abstract class StorageUploadTask {
  final FirebaseStorage _firebaseStorage;
  final String _path;
  final StorageMetadata _metadata;

  StorageUploadTask._(this._firebaseStorage, this._path, this._metadata);
  Future<void> _start();

  Completer<UploadTaskSnapshot> _completer =
      new Completer<UploadTaskSnapshot>();
  Future<UploadTaskSnapshot> get future => _completer.future;
}

class StorageFileUploadTask extends StorageUploadTask {
  final File _file;
  StorageFileUploadTask._(this._file, FirebaseStorage firebaseStorage,
      String path, StorageMetadata metadata)
      : super._(firebaseStorage, path, metadata);

  @override
  Future<void> _start() async {
    final String downloadUrl = await FirebaseStorage.channel.invokeMethod(
      'StorageReference#putFile',
      <String, dynamic>{
        'app': _firebaseStorage.app?.name,
        'bucket': _firebaseStorage.storageBucket,
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
  StorageDataUploadTask._(this._bytes, FirebaseStorage firebaseStorage,
      String path, StorageMetadata metadata)
      : super._(firebaseStorage, path, metadata);

  @override
  Future<void> _start() async {
    final String downloadUrl = await FirebaseStorage.channel.invokeMethod(
      'StorageReference#putData',
      <String, dynamic>{
        'app': _firebaseStorage.app?.name,
        'bucket': _firebaseStorage.storageBucket,
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
    'customMetadata': metadata.customMetadata,
  };
}

class UploadTaskSnapshot {
  UploadTaskSnapshot({this.downloadUrl});
  final Uri downloadUrl;
}
