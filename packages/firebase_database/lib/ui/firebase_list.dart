// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import '../firebase_database.dart' show DataSnapshot, Event, Query;
import 'utils/stream_subscriber_mixin.dart';

import 'package:meta/meta.dart';

typedef void ChildCallback(int index, DataSnapshot snapshot);
typedef void ChildMovedCallback(int fromIndex, int toIndex, DataSnapshot snapshot);
typedef void ValueCallback(DataSnapshot snapshot);

/// Base class for a list that tracks the results of a query.
///
/// You must call dispose() when the list is no longer used.
///
/// See also:
/// * ClientSortedList
/// * ServerSortedList
abstract class FirebaseList extends ListBase<DataSnapshot> with StreamSubscriberMixin<Event> {
  FirebaseList({
    @required this.query,
  }) {
    assert(query != null);
    listen(query.onValue, (_) => _completer.complete());
  }

  /// Database query used to populate the list
  final Query query;

  /// Future that completes when the data of the list has finished loading
  Future<Null> get loaded => _completer.future;
  final Completer<Null> _completer = new Completer<Null>();

  /// ListBase implementation delegates to this mutable array.
  @protected
  final List<DataSnapshot> snapshots = <DataSnapshot>[];

  // ListBase implementation
  int get length => snapshots.length;
  set length(int value) {
    throw new UnsupportedError("List cannot be modified.");
  }
  DataSnapshot operator [](int index) => snapshots[index];
  void operator []=(int index, DataSnapshot value) {
    throw new UnsupportedError("List cannot be modified.");
  }
}

