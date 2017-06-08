// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import '../firebase_database.dart' show DataSnapshot, Event, Query;
import 'firebase_list.dart';

import 'package:meta/meta.dart';

/// Sorts the results of `query` on the client side using `DataSnapshot.key`.
class ServerSortedList extends FirebaseList {
  ServerSortedList({
    @required Query query,
    this.onChildAdded,
    this.onChildRemoved,
    this.onChildChanged,
    this.onChildMoved,
  }) : super(query: query) {
    listen(query.onChildAdded, _onChildAdded);
    listen(query.onChildRemoved, _onChildRemoved);
    listen(query.onChildChanged, _onChildChanged);
    listen(query.onChildMoved, _onChildMoved);
  }

  /// Called when the child has been added
  final ChildCallback onChildAdded;

  /// Called when the child has been removed
  final ChildCallback onChildRemoved;

  /// Called when the child has changed
  final ChildCallback onChildChanged;

  /// Called when the child has moved
  final ChildMovedCallback onChildMoved;

  int _indexForKey(String key) {
    assert(key != null);
    // TODO(jackson): We could binary search since the list is already sorted.
    for (int index = 0; index < snapshots.length; index++) {
      if (key == snapshots[index].key) {
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
    snapshots.insert(index, event.snapshot);
    onChildAdded(index, event.snapshot);
  }

  void _onChildRemoved(Event event) {
    int index = _indexForKey(event.snapshot.key);
    snapshots.removeAt(index);
    onChildRemoved(index, event.snapshot);
  }

  void _onChildChanged(Event event) {
    int index = _indexForKey(event.snapshot.key);
    snapshots[index] = event.snapshot;
    onChildChanged(index, event.snapshot);
  }

  void _onChildMoved(Event event) {
    int fromIndex = _indexForKey(event.snapshot.key);
    snapshots.remove(fromIndex);

    int toIndex = 0;
    if (event.previousSiblingKey != null) {
      int prevIndex = _indexForKey(event.previousSiblingKey);
      if (prevIndex != null) {
        toIndex = prevIndex + 1;
      }
    }
    snapshots.insert(toIndex, event.snapshot);
    onChildMoved(fromIndex, toIndex, event.snapshot);
  }
}

