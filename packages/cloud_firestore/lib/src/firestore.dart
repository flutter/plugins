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
          call.arguments['data'],
          this,
        );
        _documentObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DoTransaction') {
        final int transactionId = call.arguments['transactionId'];
        return _transactionHandlers[transactionId](
            new Transaction(transactionId));
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

  /// Runs a set of atomic database operations.
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

typedef Future<Map<String, dynamic>> TransactionHandler(Transaction tx);

class Transaction {
  MethodChannel _channel;
  int _transactionId;

  Transaction(this._transactionId) : _channel = Firestore.channel;

  Future<DocumentSnapshot> get(DocumentReference documentReference) async {
    final dynamic result = await _channel.invokeMethod(
        'Transaction#get', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path
    });
    return new DocumentSnapshot._(
        documentReference.path, result['data'], Firestore.instance);
  }

  Future<Null> delete(DocumentReference documentReference) async {
    return _channel.invokeMethod('Transaction#delete', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path
    });
  }

  Future<Null> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return _channel.invokeMethod('Transaction#update', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data
    });
  }

  Future<Null> set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return _channel.invokeMethod('Transaction#set', <String, dynamic>{
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data
    });
  }
}
