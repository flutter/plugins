// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// Represents a query over the data at a particular location.
class Query {
  Query._(
      {@required Firestore firestore,
      @required List<String> pathComponents,
      Map<String, dynamic> parameters})
      : _firestore = firestore,
        _pathComponents = pathComponents,
        _parameters = parameters ??
            new Map<String, dynamic>.unmodifiable(<String, dynamic>{}),
        assert(firestore != null),
        assert(pathComponents != null);

  final Firestore _firestore;
  final List<String> _pathComponents;
  final Map<String, dynamic> _parameters;

  /// A string containing the slash-separated path to this this Query
  /// (relative to the root of the database).
  String get path => _pathComponents.join('/');

  Map<String, dynamic> buildArguments() {
    return new Map<String, dynamic>.from(_parameters)
      ..addAll(<String, dynamic>{
        'path': path,
      });
  }

  /// Notifies of query results at this location
  // TODO(jackson): Reduce code duplication with [DocumentReference]
  Stream<QuerySnapshot> get snapshots {
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshot> controller; // ignore: close_sinks
    controller = new StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        _handle = Firestore.channel.invokeMethod(
          'Query#addSnapshotListener',
          <String, dynamic>{
            'path': path,
            'parameters': _parameters,
          },
        );
        _handle.then((int handle) {
          Firestore._queryObservers[handle] = controller;
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

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReference reference() =>
      new CollectionReference._(_firestore, _pathComponents);
}
