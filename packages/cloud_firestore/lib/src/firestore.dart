// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class Firestore {
  @visibleForTesting
  static const MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  static final Map<int, StreamController<QuerySnapshot>> _queryObservers =
      <int, StreamController<QuerySnapshot>>{};

  static final Map<int, StreamController<DocumentSnapshot>> _documentObservers =
      <int, StreamController<DocumentSnapshot>>{};

  static final Map<int, TransactionHandler> _transactionHandlers =
      <int, TransactionHandler>{};
  static int _transactionHandlerId = 0;

  Firestore._() {
    channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'QuerySnapshot') {
        final QuerySnapshot snapshot =
            new QuerySnapshot._(call.arguments, this);
        _queryObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DocumentSnapshot') {
        final DocumentSnapshot snapshot = new DocumentSnapshot._(
          call.arguments['path'],
          _asStringKeyedMap(call.arguments['data']),
          this,
        );
        _documentObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DoTransaction') {
        final int transactionId = call.arguments['transactionId'];
        return _transactionHandlers[transactionId](
          new Transaction(transactionId),
        );
      }
    });
  }

  static Firestore _instance = new Firestore._();

  /// Gets the instance of Firestore for the default Firebase app.
  static Firestore get instance => _instance;

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
    final Map<String, dynamic> result = await channel.invokeMethod(
        'Firestore#runTransaction', <String, dynamic>{
      'transactionId': transactionId,
      'transactionTimeout': timeout.inMilliseconds
    });
    return result ?? <String, dynamic>{};
  }
}

typedef Future<dynamic> TransactionHandler(Transaction transaction);

class Transaction {
  int _transactionId;

  Transaction(this._transactionId);

  Future<DocumentSnapshot> get(DocumentReference documentReference) async {
    final dynamic result = await Firestore.channel
        .invokeMethod('Transaction#get', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
    if (result != null) {
      return new DocumentSnapshot._(
          documentReference.path, result['data'], Firestore.instance);
    } else {
      return null;
    }
  }

  Future<void> delete(DocumentReference documentReference) async {
    return Firestore.channel
        .invokeMethod('Transaction#delete', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
  }

  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return Firestore.channel
        .invokeMethod('Transaction#update', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }

  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return Firestore.channel.invokeMethod('Transaction#set', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }
}
