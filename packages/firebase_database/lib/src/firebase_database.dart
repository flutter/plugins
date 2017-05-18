// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// The entry point for accessing a Firebase Database. You can get an instance
/// by calling `FirebaseDatabase.instance`. To access a location in the database and
/// read or write data, use `reference()`.
class FirebaseDatabase {
  final MethodChannel _channel;

  static final Map<int, StreamController> _observers = <int, StreamController>{};

  @visibleForTesting
  FirebaseDatabase.private(this._channel) {
    _channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'Event') {
        Event event = new Event._(call.arguments);
        _observers[call.arguments['handle']].add(event);
      }
    });
  }

  factory FirebaseDatabase() {
    return new FirebaseDatabase.private(
      const MethodChannel('plugins.flutter.io/firebase_database'),
    );
  }

  static FirebaseDatabase _instance = new FirebaseDatabase();

  // Gets the instance of FirebaseDatabase for the default Firebase app.
  static FirebaseDatabase get instance => _instance;

  /// Gets a DatabaseReference for the root of your Firebase Database.
  DatabaseReference reference() => new DatabaseReference._(this, <String>[]);
}
