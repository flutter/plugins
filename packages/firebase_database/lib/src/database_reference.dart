// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// DatabaseReference represents a particular location in your Firebase
/// Database and can be used for reading or writing data to that location.
///
/// This class is the starting point for all Firebase Database operations.
/// After you’ve obtained your first DatabaseReference via
/// `FirebaseDatabase.reference()`, you can use it to read data
/// (ie. `onChildAdded`), write data (ie. `setValue`), and to create new
/// `DatabaseReference`s (ie. `child`).
class DatabaseReference extends Query {
  DatabaseReference._(FirebaseDatabase database, List<String> pathComponents)
      : super._(database: database, pathComponents: pathComponents);

  /// Gets a DatabaseReference for the location at the specified relative
  /// path. The relative path can either be a simple child key (e.g. ‘fred’) or
  /// a deeper slash-separated path (e.g. ‘fred/name/first’).
  DatabaseReference child(String path) {
    return new DatabaseReference._(_database,
        (new List<String>.from(_pathComponents)..addAll(path.split('/'))));
  }

  /// Gets a DatabaseReference for the parent location. If this instance
  /// refers to the root of your Firebase Database, it has no parent, and
  /// therefore parent() will return null.
  DatabaseReference parent() {
    if (_pathComponents.isEmpty) {
      return null;
    }
    return new DatabaseReference._(
        _database, (new List<String>.from(_pathComponents)..removeLast()));
  }

  /// Gets a FIRDatabaseReference for the root location.
  DatabaseReference root() {
    return new DatabaseReference._(_database, <String>[]);
  }

  /// Gets the last token in a Firebase Database location (e.g. ‘fred’ in
  /// https://SampleChat.firebaseIO-demo.com/users/fred)
  String get key => _pathComponents.last;

  /// Generates a new child location using a unique key and returns a
  /// DatabaseReference to it. This is useful when the children of a Firebase
  /// Database location represent a list of items.
  ///
  /// The unique key generated by childByAutoId: is prefixed with a
  /// client-generated timestamp so that the resulting list will be
  /// chronologically-sorted.
  DatabaseReference push() {
    final String key = PushIdGenerator.generatePushChildName();
    final List<String> childPath = new List<String>.from(_pathComponents)
      ..add(key);
    return new DatabaseReference._(_database, childPath);
  }

  /// Write `value` to the location with the specified `priority` if applicable.
  ///
  /// This will overwrite any data at this location and all child locations.
  ///
  /// Data types that are allowed are String, boolean, int, double, Map, List.
  ///
  /// The effect of the write will be visible immediately and the corresponding
  /// events will be triggered. Synchronization of the data to the Firebase
  /// Database servers will also be started.
  ///
  /// Passing null for the new value means all data at this location or any
  /// child location will be deleted.
  Future<Null> set(dynamic value, {dynamic priority}) {
    return _database._channel.invokeMethod(
      'DatabaseReference#set',
      <String, dynamic>{
        'app': _database.app?.name,
        'path': path,
        'value': value,
        'priority': priority,
      },
    );
  }

  /// Update the node with the `value`
  Future<Null> update(Map<String, dynamic> value) {
    return _database._channel.invokeMethod(
      'DatabaseReference#update',
      <String, dynamic>{
        'app': _database.app?.name,
        'path': path,
        'value': value,
      },
    );
  }

  /// Sets a priority for the data at this Firebase Database location.
  ///
  /// Priorities can be used to provide a custom ordering for the children at a
  /// location (if no priorities are specified, the children are ordered by
  /// key).
  ///
  /// You cannot set a priority on an empty location. For this reason
  /// set() should be used when setting initial data with a specific priority
  /// and setPriority() should be used when updating the priority of existing
  /// data.
  ///
  /// Children are sorted based on this priority using the following rules:
  ///
  /// Children with no priority come first. Children with a number as their
  /// priority come next. They are sorted numerically by priority (small to
  /// large). Children with a string as their priority come last. They are
  /// sorted lexicographically by priority. Whenever two children have the same
  /// priority (including no priority), they are sorted by key. Numeric keys
  /// come first (sorted numerically), followed by the remaining keys (sorted
  /// lexicographically).
  ///
  /// Note that priorities are parsed and ordered as IEEE 754 double-precision
  /// floating-point numbers. Keys are always stored as strings and are treated
  /// as numbers only when they can be parsed as a 32-bit integer.
  Future<Null> setPriority(dynamic priority) async {
    return _database._channel.invokeMethod(
      'DatabaseReference#setPriority',
      <String, dynamic>{
        'app': _database.app?.name,
        'path': path,
        'priority': priority,
      },
    );
  }

  /// Remove the data at this Firebase Database location. Any data at child
  /// locations will also be deleted.
  ///
  /// The effect of the delete will be visible immediately and the corresponding
  /// events will be triggered. Synchronization of the delete to the Firebase
  /// Database servers will also be started.
  ///
  /// remove() is equivalent to calling set(null)
  Future<Null> remove() => set(null);

  /// Performs an optimistic-concurrency transactional update to the data at
  /// this Firebase Database location.
  Future<TransactionResult> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout: const Duration(seconds: 5)}) async {
    assert(timeout.inMilliseconds > 0,
        'Transaction timeout must be more than 0 milliseconds.');

    final Completer<TransactionResult> completer =
        new Completer<TransactionResult>();

    final int transactionKey = FirebaseDatabase._transactions.isEmpty
        ? 0
        : FirebaseDatabase._transactions.keys.last + 1;

    FirebaseDatabase._transactions[transactionKey] = transactionHandler;

    _database._channel
        .invokeMethod('DatabaseReference#runTransaction', <String, dynamic>{
      'app': _database.app?.name,
      'path': path,
      'transactionKey': transactionKey,
      'transactionTimeout': timeout.inMilliseconds
    }).then((Map<String, dynamic> result) {
      final DatabaseError databaseError =
          result['error'] != null ? new DatabaseError._(result['error']) : null;
      final bool committed = result['committed'];
      final DataSnapshot dataSnapshot = result['snapshot'] != null
          ? new DataSnapshot._(result['snapshot'])
          : null;

      FirebaseDatabase._transactions.remove(transactionKey);

      completer.complete(
          new TransactionResult._(databaseError, committed, dataSnapshot));
    });

    return completer.future;
  }
}

class ServerValue {
  static const Map<String, String> timestamp = const <String, String>{
    '.sv': 'timestamp'
  };
}

typedef Future<MutableData> TransactionHandler(MutableData mutableData);

class TransactionResult {
  const TransactionResult._(this.error, this.committed, this.dataSnapshot);
  final DatabaseError error;
  final bool committed;
  final DataSnapshot dataSnapshot;
}
