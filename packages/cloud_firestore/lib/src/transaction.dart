// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

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
      return new DocumentSnapshot._(documentReference.path,
          result['data'].cast<String, dynamic>(), Firestore.instance);
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
