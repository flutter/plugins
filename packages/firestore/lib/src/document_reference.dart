// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firestore;

/// A DocumentReference refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A DocumentReference can also be used to create a CollectionReference
/// to a subcollection.
class DocumentReference {
  DocumentReference._(Firestore firestore, List<String> pathComponents)
    : _firestore = firestore,
      _pathComponents = pathComponents,
      assert(firestore != null);

  final Firestore _firestore;
  final List<String> _pathComponents;

  /// Slash-delimited path representing the database location of this query.
  String get path => _pathComponents.join('/');

  Future<Null> setData(Map<String, dynamic> data) {
    return _firestore._channel.invokeMethod(
      'DocumentReference#setData',
      <String, dynamic>{'path': path, 'data': data},
    );
  }
}
