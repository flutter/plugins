// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_firestore;

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
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
    return Firestore.channel.invokeMethod(
      'DocumentReference#setData',
      <String, dynamic>{'path': path, 'data': data},
    );
  }

  /// Notifies of documents at this location
  // TODO(jackson): Reduce code duplication with [Query]
  Stream<DocumentSnapshot> get snapshots {
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<DocumentSnapshot> controller; // ignore: close_sinks
    controller = new StreamController<DocumentSnapshot>.broadcast(
      onListen: () {
        _handle = Firestore.channel.invokeMethod(
          'Query#addDocumentListener',
          <String, dynamic>{
            'path': path,
          },
        );
        _handle.then((int handle) {
          Firestore._documentObservers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await Firestore.channel.invokeMethod(
            'Query#removeListener',
            <String, dynamic>{'handle': handle},
          );
          Firestore._queryObservers.remove(handle);
        });
      },
    );
    return controller.stream;
  }
}
