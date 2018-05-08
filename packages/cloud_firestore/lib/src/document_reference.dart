// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
class DocumentReference {
  DocumentReference._(this.firestore, List<String> pathComponents)
      : _pathComponents = pathComponents,
        assert(firestore != null);

  /// The Firestore instance associated with this document reference
  final Firestore firestore;

  final List<String> _pathComponents;

  @override
  bool operator ==(dynamic o) =>
      o is DocumentReference && o.firestore == firestore && o.path == path;

  @override
  int get hashCode => hashList(_pathComponents);

  /// Slash-delimited path representing the database location of this query.
  String get path => _pathComponents.join('/');

  /// This document's given or generated ID in the collection.
  String get documentID => _pathComponents.last;

  /// Writes to the document referred to by this [DocumentReference].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  Future<void> setData(Map<String, dynamic> data, {bool merge: false}) {
    return Firestore.channel.invokeMethod(
      'DocumentReference#setData',
      <String, dynamic>{
        'app': firestore.app.name,
        'path': path,
        'data': data,
        'options': <String, bool>{'merge': merge},
      },
    );
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// If no document exists yet, the update will fail.
  Future<void> updateData(Map<String, dynamic> data) {
    return Firestore.channel.invokeMethod(
      'DocumentReference#updateData',
      <String, dynamic>{
        'app': firestore.app.name,
        'path': path,
        'data': data,
      },
    );
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<DocumentSnapshot> get() async {
    final Map<dynamic, dynamic> result = await Firestore.channel.invokeMethod(
      'DocumentReference#get',
      <String, dynamic>{'app': firestore.app.name, 'path': path},
    );
    return new DocumentSnapshot._(result, firestore);
  }

  /// Deletes the document referred to by this [DocumentReference].
  Future<void> delete() {
    return Firestore.channel.invokeMethod(
      'DocumentReference#delete',
      <String, dynamic>{'app': firestore.app.name, 'path': path},
    );
  }

  /// Returns the reference of a collection contained inside of this
  /// document.
  CollectionReference collection(String collectionPath) {
    return firestore.collection(
      <String>[path, collectionPath].join('/'),
    );
  }

  /// [DocumentSnapshot] events corresponding to this reference's location
  ///
  /// If [includeMetadataChanges] is true, both document and query metadata
  /// changes are included.

  Stream<DocumentSnapshot> snapshots({ bool includeMetadataChanges: false }) {
    return Firestore._snapshots(
      onListen: (int handle) {
        Firestore.channel.invokeMethod(
          'DocumentReference#addDocumentListener',
          <String, dynamic>{
            'handle': handle,
            'app': firestore.app.name,
            'path': path,
            'includeMetadataChanges': includeMetadataChanges,
          },
        );
      },
      onCancel: (int handle) {
        Firestore.channel.invokeMethod(
          'DocumentReference#removeListener',
          <String, dynamic>{'handle': handle},
        );
      },
    ).map((Map<dynamic, dynamic> snapshot) {
      return new DocumentSnapshot._(snapshot, this.firestore);
    });
  }
}
