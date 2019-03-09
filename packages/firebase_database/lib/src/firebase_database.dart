// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// The entry point for accessing a Firebase Database. You can get an instance
/// by calling `FirebaseDatabase.instance`. To access a location in the database
/// and read or write data, use `reference()`.
class FirebaseDatabase {
  /// Gets an instance of [FirebaseDatabase].
  ///
  /// If [app] is specified, its options should include a [databaseURL].
  FirebaseDatabase({this.app, this.databaseURL}) {
    if (_initialized) return;
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'Event':
          final Event event = Event._(call.arguments);
          _observers[call.arguments['handle']].add(event);
          return null;
        case 'Error':
          final DatabaseError error = DatabaseError._(call.arguments['error']);
          _observers[call.arguments['handle']].addError(error);
          return null;
        case 'DoTransaction':
          final MutableData mutableData =
              MutableData.private(call.arguments['snapshot']);
          final MutableData updated =
              await _transactions[call.arguments['transactionKey']](
                  mutableData);
          return <String, dynamic>{'value': updated.value};
        default:
          throw MissingPluginException(
            '${call.method} method not implemented on the Dart side.',
          );
      }
    });
    _initialized = true;
  }

  static final Map<int, StreamController<Event>> _observers =
      <int, StreamController<Event>>{};

  static final Map<int, TransactionHandler> _transactions =
      <int, TransactionHandler>{};

  static bool _initialized = false;

  static FirebaseDatabase _instance = FirebaseDatabase();

  final MethodChannel _channel = const MethodChannel(
    'plugins.flutter.io/firebase_database',
  );

  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  final FirebaseApp app;

  /// The URL to which this [FirebaseDatabase] belongs
  ///
  /// If null, the URL of the specified [FirebaseApp] is used
  final String databaseURL;

  /// Gets the instance of FirebaseDatabase for the default Firebase app.
  static FirebaseDatabase get instance => _instance;

  /// Gets a DatabaseReference for the root of your Firebase Database.
  DatabaseReference reference() => DatabaseReference._(this, <String>[]);

  /// Attempts to sets the database persistence to [enabled].
  ///
  /// This property must be set before calling methods on database references
  /// and only needs to be called once per application. The returned [Future]
  /// will complete with `true` if the operation was successful or `false` if
  /// the persistence could not be set (because database references have
  /// already been created).
  ///
  /// The Firebase Database client will cache synchronized data and keep track
  /// of all writes you’ve initiated while your application is running. It
  /// seamlessly handles intermittent network connections and re-sends write
  /// operations when the network connection is restored.
  ///
  /// However by default your write operations and cached data are only stored
  /// in-memory and will be lost when your app restarts. By setting [enabled]
  /// to `true`, the data will be persisted to on-device (disk) storage and will
  /// thus be available again when the app is restarted (even when there is no
  /// network connectivity at that time).
  Future<bool> setPersistenceEnabled(bool enabled) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final bool result = await _channel.invokeMethod(
      'FirebaseDatabase#setPersistenceEnabled',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
        'enabled': enabled,
      },
    );
    return result;
  }

  /// Attempts to set the size of the persistence cache.
  ///
  /// By default the Firebase Database client will use up to 10MB of disk space
  /// to cache data. If the cache grows beyond this size, the client will start
  /// removing data that hasn’t been recently used. If you find that your
  /// application caches too little or too much data, call this method to change
  /// the cache size.
  ///
  /// This property must be set before calling methods on database references
  /// and only needs to be called once per application. The returned [Future]
  /// will complete with `true` if the operation was successful or `false` if
  /// the value could not be set (because database references have already been
  /// created).
  ///
  /// Note that the specified cache size is only an approximation and the size
  /// on disk may temporarily exceed it at times. Cache sizes smaller than 1 MB
  /// or greater than 100 MB are not supported.
  Future<bool> setPersistenceCacheSizeBytes(int cacheSize) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final bool result = await _channel.invokeMethod(
      'FirebaseDatabase#setPersistenceCacheSizeBytes',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
        'cacheSize': cacheSize,
      },
    );
    return result;
  }

  /// Resumes our connection to the Firebase Database backend after a previous
  /// [goOffline] call.
  Future<void> goOnline() {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod(
      'FirebaseDatabase#goOnline',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
      },
    );
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  Future<void> goOffline() {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod(
      'FirebaseDatabase#goOffline',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
      },
    );
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
  Future<void> purgeOutstandingWrites() {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod(
      'FirebaseDatabase#purgeOutstandingWrites',
      <String, dynamic>{
        'app': app?.name,
        'databaseURL': databaseURL,
      },
    );
  }
}
