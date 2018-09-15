// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [Query]).
class CollectionReference extends Query {
  CollectionReference._(Firestore firestore, List<String> pathComponents)
      : super._(firestore: firestore, pathComponents: pathComponents);

  /// ID of the referenced collection.
  String get id => _pathComponents.isEmpty ? null : _pathComponents.last;

  /// For subcollections, parent returns the containing DocumentReference.
  ///
  /// For root collections, null is returned.
  CollectionReference parent() {
    if (_pathComponents.isEmpty) {
      return null;
    }
    return CollectionReference._(
      firestore,
      (List<String>.from(_pathComponents)..removeLast()),
    );
  }

  /// A string containing the slash-separated path to this  CollectionReference
  /// (relative to the root of the database).
  String get path => _path;

  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentReference document([String path]) {
    List<String> childPath;
    if (path == null) {
      final String key = PushIdGenerator.generatePushChildName();
      childPath = List<String>.from(_pathComponents)..add(key);
    } else {
      childPath = List<String>.from(_pathComponents)..addAll(path.split(('/')));
    }
    return DocumentReference._(firestore, childPath);
  }

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final DocumentReference newDocument = document();
    await newDocument.setData(data);
    return newDocument;
  }
}
