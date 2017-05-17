// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

enum _EventType {
  /// fired when a new child node is added to a location
  childAdded,

  // fired when a child node is removed from a location
  childRemoved,

  // fired when a child node at a location changes
  childChanged,

  // fired when a child node moves relative to the other child nodes at a location
  childMoved,

  // fired when any data changes at a location and, recursively, any children
  value
}

class Event {
  Map<String, dynamic> _data;
  Event._(this._data) : snapshot = new DataSnapshot._(_data['snapshot']);
  final DataSnapshot snapshot;
  String get previousSiblingKey => _data['previousSiblingKey'];
}

class DataSnapshot {
  Map<String, dynamic> _data;
  DataSnapshot._(this._data);
  String get key => _data['key'];
  dynamic get value => _data['value'];
}
