// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirebaseDatabase {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/firebase_database');

  FirebaseDatabase() {
    // stub implementation
    _channel.setMethodCallHandler((MethodCall call) {
      if (call.method == "DatabaseReference#childAdded") {
        Event event = new Event._(call.arguments[0], call.arguments[1]);
        Query._childAdded.add(event);
      }
    });
  }

  static FirebaseDatabase _instance = new FirebaseDatabase();
  static FirebaseDatabase get instance => _instance;
  DatabaseReference reference() => new DatabaseReference();
}

class Query {
  // stub implementation
  static StreamController<Event> _childAdded = new StreamController<Event>.broadcast();
  Stream<Event> get onChildAdded => _childAdded.stream;
}

class DatabaseReference extends Query {
  DatabaseReference push() => new DatabaseReference();   // stub implementation
  DatabaseReference child(String name) => new DatabaseReference();  // stub implementation

  Future set(Map<String, dynamic> value) async {
    await FirebaseDatabase._channel.invokeMethod(
      "DatabaseReference#set",
      [value]
    );
    return value;
  }
}

class Event {
  Event._(String key, dynamic value) : snapshot = new DataSnapshot(key, value);
  final DataSnapshot snapshot;
}

class DataSnapshot {
  final String key;
  final dynamic value;
  DataSnapshot(this.key, this.value);
}
