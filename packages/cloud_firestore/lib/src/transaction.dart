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
    final dynamic result = await Firestore.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('Transaction#get', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
    if (result != null) {
      return DocumentSnapshot._(documentReference.path,
          result['data']?.cast<String, dynamic>(), Firestore.instance);
    } else {
      return null;
    }
  }

  Future<void> delete(DocumentReference documentReference) async {
    return Firestore.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('Transaction#delete', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
    });
  }

  Future<void> update(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    return Firestore.channel
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        .invokeMethod('Transaction#update', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }

  Future<void> set(
      DocumentReference documentReference, Map<String, dynamic> data) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return Firestore.channel.invokeMethod('Transaction#set', <String, dynamic>{
      'app': _firestore.app.name,
      'transactionId': _transactionId,
      'path': documentReference.path,
      'data': data,
    });
  }
}
