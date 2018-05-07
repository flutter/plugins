// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

typedef _ListenCallback(int handle);
typedef _CancelCallback(int handle);

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  @visibleForTesting
  static const MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/cloud_firestore',
    const StandardMethodCodec(const FirestoreMessageCodec()),
  );

  static int _nextHandle = 0;
  static final Map<int, StreamController<Map<dynamic, dynamic>>> _streamControllers =
      <int, StreamController<Map<dynamic, dynamic>>>{};

  static final Map<int, TransactionHandler> _transactionHandlers =
      <int, TransactionHandler>{};
  static int _transactionHandlerId = 0;

  static Future<void> _handleMethodCall(MethodCall call) async {
    final Map<dynamic, dynamic> result = call.arguments;
    final FirebaseApp app = await FirebaseApp.appNamed(result['app']);
    final Firestore firestore = new Firestore(app: app);
    if (call.method == 'QuerySnapshot' || call.method == 'DocumentSnapshot') {
      final int handle = call.arguments['handle'];
      _streamControllers[handle]?.add(result['snapshot']);
    } else if (call.method == 'DoTransaction') {
      final int transactionId = result['transactionId'];
      return _transactionHandlers[transactionId](
        new Transaction(transactionId, firestore),
      );
    }
  }

  // Utility method used by Query and DocumentReference to retrieve a stream
  // of snapshots
  static Stream<Map<dynamic, dynamic>> _snapshots({
    _ListenCallback onListen,
    _CancelCallback onCancel,
  }) {
    final int handle = _nextHandle++;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<Map<dynamic, dynamic>> controller; // ignore: close_sinks
    controller = new StreamController<Map<dynamic, dynamic>>.broadcast(
      onListen: () {
        _streamControllers[handle] = controller;
        onListen(handle);
      },
      onCancel: () {
        _streamControllers.remove(handle);
        onCancel(handle);
      },
    );
    return controller.stream;
  }

  Firestore({FirebaseApp app}) : this.app = app ?? FirebaseApp.instance {
    channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Gets the instance of Firestore for the default Firebase app.
  static final Firestore instance = new Firestore();

  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.
  final FirebaseApp app;

  @override
  bool operator ==(dynamic o) => o is Firestore && o.app == app;

  @override
  int get hashCode => app.hashCode;

  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReference collection(String path) {
    assert(path != null);
    return new CollectionReference._(this, path.split('/'));
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReference document(String path) {
    assert(path != null);
    return new DocumentReference._(this, path.split('/'));
  }

  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  ///
  /// Unlike transactions, write batches are persisted offline and therefore are
  /// preferable when you don’t need to condition your writes on read data.
  WriteBatch batch() => new WriteBatch._(this);

  /// Executes the given TransactionHandler and then attempts to commit the
  /// changes applied within an atomic transaction.
  ///
  /// In the TransactionHandler, a set of reads and writes can be performed
  /// atomically using the Transaction object passed to the TransactionHandler.
  /// After the TransactionHandler is run, Firestore will attempt to apply the
  /// changes to the server. If any of the data read has been modified outside
  /// of this transaction since being read, then the transaction will be
  /// retried by executing the updateBlock again. If the transaction still
  /// fails after 5 retries, then the transaction will fail.
  ///
  /// The TransactionHandler may be executed multiple times, it should be able
  /// to handle multiple executions.
  ///
  /// Data accessed with the transaction will not reflect local changes that
  /// have not been committed. For this reason, it is required that all
  /// reads are performed before any writes. Transactions must be performed
  /// while online. Otherwise, reads will fail, and the final commit will fail.
  ///
  /// By default transactions are limited to 5 seconds of execution time. This
  /// timeout can be adjusted by setting the timeout parameter.
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout: const Duration(seconds: 5)}) async {
    assert(timeout.inMilliseconds > 0,
        'Transaction timeout must be more than 0 milliseconds');
    final int transactionId = _transactionHandlerId++;
    _transactionHandlers[transactionId] = transactionHandler;
    final Map<dynamic, dynamic> result = await channel
        .invokeMethod('Firestore#runTransaction', <String, dynamic>{
      'app': app.name,
      'transactionId': transactionId,
      'transactionTimeout': timeout.inMilliseconds
    });
    return result?.cast<String, dynamic>() ?? <String, dynamic>{};
  }
}
