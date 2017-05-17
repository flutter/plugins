// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

class DatabaseReference extends Query {
  DatabaseReference._(FirebaseDatabase database, List<String> pathComponents)
    : super._(database, pathComponents);

  DatabaseReference child(String path) {
    return new DatabaseReference._(
      _database,
      (new List<String>.from(_pathComponents)..addAll(path.split("/")))
    );
  }

  DatabaseReference parent() {
    return new DatabaseReference._(
      _database,
      (new List<String>.from(_pathComponents)..removeLast())
    );
  }

  DatabaseReference root() {
    return new DatabaseReference._(_database, <String>[]);
  }

  String get key => _pathComponents.last;

  DatabaseReference push() {
    String key = PushIdGenerator.generatePushChildName();
    List<String> childPath = new List<String>.from(_pathComponents)..add(key);
    return new DatabaseReference._(_database, childPath);
  }

  Future<Null> set(Map<String, dynamic> values) async {
    await _database._channel.invokeMethod(
      "DatabaseReference#set",
      { 'path': path, 'values': values },
    );
  }

  Future<Null> setValue(dynamic value) async {
    await _database._channel.invokeMethod(
      "DatabaseReference#setValue",
      { 'path': path, 'value': value },
    );
  }
}
