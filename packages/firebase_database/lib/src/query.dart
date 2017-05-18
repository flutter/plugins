// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// Represents a query over the data at a particular location.
class Query {
  Query._(this._database, this._pathComponents)
    : path = _pathComponents.join('/');

  final FirebaseDatabase _database;
  final List<String> _pathComponents;

  /// Slash-delimited path representing the database location of this query.
  final String path;

  Stream<Event> _observe(_EventType eventType) {
    Future<int> _handle;
    StreamController<Event> controller;
    controller = new StreamController<Event>.broadcast(
      onListen: () async {
        _handle = _database._channel.invokeMethod(
          'Query#observe',
          { 'path': path, 'eventType': eventType.toString() },
        );
        _handle.then((int handle) {
          FirebaseDatabase._observers[handle] = controller;
        });
      },
      onCancel: () async {
        int handle = await _handle;
        await _database._channel.invokeMethod(
          'Query#removeObserver',
          { 'handle': handle },
        );
        FirebaseDatabase._observers.remove(handle);
      },
    );
    return controller.stream;
  }

  /// Gets a single value event.
  Future<DataSnapshot> once() async => (await onValue.first).snapshot;

  /// Fires when children are added.
  Stream<Event> get onChildAdded => _observe(_EventType.childAdded);

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<Event> get onChildRemoved => _observe(_EventType.childRemoved);

  /// Fires when children are changed.
  Stream<Event> get onChildChanged => _observe(_EventType.childChanged);

  /// Fires when children are moved.
  Stream<Event> get onChildMoved => _observe(_EventType.childMoved);

  /// Fires the data at this location is updated. `previousChildKey` is null.
  Stream<Event> get onValue => _observe(_EventType.value);
}
