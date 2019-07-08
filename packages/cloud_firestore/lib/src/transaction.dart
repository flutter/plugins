// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

typedef Future<dynamic> TransactionHandler(Transaction transaction);

class Transaction {
  @visibleForTesting
  Transaction(this._transactionId, this._firestore);

  int _transactionId;
  Firestore _firestore;
  List<Future<dynamic>> _pendingResults = <Future<dynamic>>[];
  Future<void> _finish() => Future.wait<void>(_pendingResults);

  /// Reads the document referenced by the provided DocumentReference.
  Future<DocumentSnapshot> get(DocumentReference documentReference) {
    final Future<DocumentSnapshot> result = _get(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<DocumentSnapshot> _get(DocumentReference documentReference) async {
    final Map<String, dynamic> result = await Firestore.channel
        .invokeMapMethod<String, dynamic>('Transaction#get', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
    if (result != null) {
      return DocumentSnapshot._(
          documentReference.path,
          result['data']?.cast<String, dynamic>(),
          SnapshotMetadata._(result['metadata']['hasPendingWrites'],
              result['metadata']['isFromCache']),
          _firestore);
    } else {
      return null;
    }
  }

  /// Deletes the document referred to by the provided [documentReference].
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> delete(DocumentReference documentReference) {
    final Future<void> result = _delete(documentReference);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _delete(DocumentReference documentReference) async {
    return Firestore.channel
        .invokeMethod<void>('Transaction#delete', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
  }

  /// Updates fields in the document referred to by [documentReference].
  /// The update will fail if applied to a document that does not exist.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    final Future<void> result = _update(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return Firestore.channel
        .invokeMethod<void>('Transaction#update', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }

  /// Writes to the document referred to by the provided [DocumentReference].
  /// If the document does not exist yet, it will be created. If you pass
  /// SetOptions, the provided data can be merged into the existing document.
  ///
  /// Awaiting the returned [Future] is optional and will be done automatically
  /// when the transaction handler completes.
  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) {
    final Future<void> result = _set(documentReference, data);
    _pendingResults.add(result);
    return result;
  }

  Future<void> _set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return Firestore.channel
        .invokeMethod<void>('Transaction#set', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }
}
