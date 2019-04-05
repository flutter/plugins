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

  Future<DocumentSnapshot> get(DocumentReference documentReference) async {
    final Map<dynamic, dynamic> result = await Firestore.channel
        .invokeMethod<Map<dynamic, dynamic>>(
            'Transaction#get', <String, dynamic>{
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

  Future<void> delete(DocumentReference documentReference) async {
    return Firestore.channel
        .invokeMethod<void>('Transaction#delete', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
  }

  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return Firestore.channel
        .invokeMethod<void>('Transaction#update', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }

  Future<void> set(
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
