// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

enum _EventType {
  childAdded,
  childRemoved,
  childChanged,
  childMoved,
  value,
}

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class Event {
  Map<String, dynamic> _data;
  Event._(this._data) : snapshot = new DataSnapshot._(_data['snapshot']);

  final DataSnapshot snapshot;
  String get previousSiblingKey => _data['previousSiblingKey'];
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshot {
  Map<String, dynamic> _data;
  DataSnapshot._(this._data);

  /// The key of the location that generated this DataSnapshot.
  String get key => _data['key'];

  /// Returns the contents of this data snapshot as native types.
  dynamic get value => _data['value'];
}
