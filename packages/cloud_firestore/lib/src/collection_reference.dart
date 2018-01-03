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

  /// For subcollections, parent returns the containing DocumentReference.
  ///
  /// For root collections, null is returned.
  CollectionReference parent() {
    if (_pathComponents.isEmpty) {
      return null;
    }
    return new CollectionReference._(
        _firestore, (new List<String>.from(_pathComponents)..removeLast()));
  }

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
      childPath = new List<String>.from(_pathComponents)..add(key);
    } else {
      childPath = new List<String>.from(_pathComponents)
        ..addAll(path.split(('/')));
    }
    return new DocumentReference._(_firestore, childPath);
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

class ServerValue {
  static const Map<String, String> timestamp = const <String, String>{
    '.sv': 'timestamp'
  };
}
