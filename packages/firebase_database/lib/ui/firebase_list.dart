// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../firebase_database.dart'
    show DatabaseError, DataSnapshot, Event, Query;
import 'utils/stream_subscriber_mixin.dart';

typedef void ChildCallback(int index, DataSnapshot snapshot);
typedef void ChildMovedCallback(
    int fromIndex, int toIndex, DataSnapshot snapshot);
typedef void ValueCallback(DataSnapshot snapshot);
typedef void ErrorCallback(DatabaseError error);

/// Sorts the results of `query` on the client side using `DataSnapshot.key`.
class FirebaseList extends ListBase<DataSnapshot>
    with StreamSubscriberMixin<Event> {
  FirebaseList({
    @required this.query,
    this.onChildAdded,
    this.onChildRemoved,
    this.onChildChanged,
    this.onChildMoved,
    this.onValue,
    this.onError,
  }) {
    assert(query != null);
    listen(query.onChildAdded, _onChildAdded, onError: _onError);
    listen(query.onChildRemoved, _onChildRemoved, onError: _onError);
    listen(query.onChildChanged, _onChildChanged, onError: _onError);
    listen(query.onChildMoved, _onChildMoved, onError: _onError);
    listen(query.onValue, _onValue, onError: _onError);
  }

  /// Database query used to populate the list
  final Query query;

  /// Called when the child has been added
  final ChildCallback onChildAdded;

  /// Called when the child has been removed
  final ChildCallback onChildRemoved;

  /// Called when the child has changed
  final ChildCallback onChildChanged;

  /// Called when the child has moved
  final ChildMovedCallback onChildMoved;

  /// Called when the data of the list has finished loading
  final ValueCallback onValue;

  /// Called when an error is reported (e.g. permission denied)
  final ErrorCallback onError;

  // ListBase implementation
  final List<DataSnapshot> _snapshots = <DataSnapshot>[];

  @override
  int get length => _snapshots.length;

  @override
  set length(int value) {
    throw UnsupportedError("List cannot be modified.");
  }

  @override
  DataSnapshot operator [](int index) => _snapshots[index];

  @override
  void operator []=(int index, DataSnapshot value) {
    throw UnsupportedError("List cannot be modified.");
  }

  @override
  void clear() {
    cancelSubscriptions();

    // Do not call super.clear(), it will set the length, it's unsupported.
  }

  int _indexForKey(String key) {
    assert(key != null);
    for (int index = 0; index < _snapshots.length; index++) {
      if (key == _snapshots[index].key) {
        return index;
      }
    }
    return null;
  }

  void _onChildAdded(Event event) {
    int index = 0;
    if (event.previousSiblingKey != null) {
      index = _indexForKey(event.previousSiblingKey) + 1;
    }
    _snapshots.insert(index, event.snapshot);
    onChildAdded(index, event.snapshot);
  }

  void _onChildRemoved(Event event) {
    final int index = _indexForKey(event.snapshot.key);
    _snapshots.removeAt(index);
    onChildRemoved(index, event.snapshot);
  }

  void _onChildChanged(Event event) {
    final int index = _indexForKey(event.snapshot.key);
    _snapshots[index] = event.snapshot;
    onChildChanged(index, event.snapshot);
  }

  void _onChildMoved(Event event) {
    final int fromIndex = _indexForKey(event.snapshot.key);
    _snapshots.removeAt(fromIndex);

    int toIndex = 0;
    if (event.previousSiblingKey != null) {
      final int prevIndex = _indexForKey(event.previousSiblingKey);
      if (prevIndex != null) {
        toIndex = prevIndex + 1;
      }
    }
    _snapshots.insert(toIndex, event.snapshot);
    onChildMoved(fromIndex, toIndex, event.snapshot);
  }

  void _onValue(Event event) {
    onValue(event.snapshot);
  }

  void _onError(Object o) {
    final DatabaseError error = o;
    onError?.call(error);
  }
}
