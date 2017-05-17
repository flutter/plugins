// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

class FirebaseDatabase {
  final MethodChannel _channel;

  static final Map<int, StreamController> _observers = <int, StreamController>{};

  @visibleForTesting
  FirebaseDatabase.private(this._channel) {
    _channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'Event') {
        Event event = new Event._(call.arguments);
        _observers[call.arguments["handle"]].add(event);
      }
    });
  }

  factory FirebaseDatabase() {
    return new FirebaseDatabase.private(
      const MethodChannel('plugins.flutter.io/firebase_database'),
    );
  }

  static FirebaseDatabase _instance = new FirebaseDatabase();
  static FirebaseDatabase get instance => _instance;
  DatabaseReference reference() => new DatabaseReference._(this, <String>[]);
}
