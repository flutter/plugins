// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// The entry point for accessing a Firebase Database. You can get an instance
/// by calling `FirebaseDatabase.instance`. To access a location in the database
/// and read or write data, use `reference()`.
class FirebaseDatabase {
  final MethodChannel _channel = const MethodChannel(
    'plugins.flutter.io/firebase_database',
  );

  static final Map<int, StreamController> _observers = <int, StreamController>{};

  FirebaseDatabase._() {
    _channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'Event') {
        Event event = new Event._(call.arguments);
        _observers[call.arguments['handle']].add(event);
      }
    });
  }

  static FirebaseDatabase _instance = new FirebaseDatabase._();

  /// Gets the instance of FirebaseDatabase for the default Firebase app.
  static FirebaseDatabase get instance => _instance;

  /// Gets a DatabaseReference for the root of your Firebase Database.
  DatabaseReference reference() => new DatabaseReference._(this, <String>[]);

  /// The Firebase Database client will cache synchronized data and keep track
  /// of all writes you’ve initiated while your application is running. It
  /// seamlessly handles intermittent network connections and re-sends write
  /// operations when the network connection is restored.
  ///
  /// However by default your write operations and cached data are only stored
  /// in-memory and will be lost when your app restarts. By setting this value
  /// to YES, the data will be persisted to on-device (disk) storage and will
  /// thus be available again when the app is restarted (even when there is no
  /// network connectivity at that time). Note that this property must be set
  /// before creating your first Database reference and only needs to be called
  /// once per application.
  Future<Null> setPersistenceEnabled(bool enabled) {
    return _channel.invokeMethod(
      "FirebaseDatabase#setPersistenceEnabled",
      { 'enabled': enabled },
    );
  }

  /// By default the Firebase Database client will use up to 10MB of disk space
  /// to cache data. If the cache grows beyond this size, the client will start
  /// removing data that hasn’t been recently used. If you find that your
  /// application caches too little or too much data, call this method to change
  /// the cache size. This property must be set before creating your first
  /// FIRDatabaseReference and only needs to be called once per application.
  ///
  /// Note that the specified cache size is only an approximation and the size
  /// on disk may temporarily exceed it at times. Cache sizes smaller than 1 MB
  /// or greater than 100 MB are not supported.
  Future<Null> setPersistenceCacheSizeBytes(int cacheSize) {
    return _channel.invokeMethod(
      "FirebaseDatabase#setPersistenceCacheSizeBytes",
      { 'cacheSize': cacheSize },
    );
  }

  /// Resumes our connection to the Firebase Database backend after a previous
  /// goOffline call.
  Future<Null> goOnline() {
    return _channel.invokeMethod("FirebaseDatabase#goOnline");
  }

  /// Shuts down our connection to the Firebase Database backend until goOnline
  /// is called.
  Future<Null> goOffline() {
    return _channel.invokeMethod("FirebaseDatabase#goOffline");
  }

  /// The Firebase Database client automatically queues writes and sends them to
  /// the server at the earliest opportunity, depending on network connectivity.
  /// In some cases (e.g. offline usage) there may be a large number of writes
  /// waiting to be sent. Calling this method will purge all outstanding writes
  /// so they are abandoned.
  ///
  /// All writes will be purged, including transactions and onDisconnect writes.
  /// The writes will be rolled back locally, perhaps triggering events for
  /// affected event listeners, and the client will not (re-)send them to the
  /// Firebase Database backend.
  Future<Null> purgeOutstandingWrites() {
    return _channel.invokeMethod("FirebaseDatabase#purgeOutstandingWrites");
  }
}
