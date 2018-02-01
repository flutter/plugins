// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new MaterialApp(title: 'Firestore Example', home: new MyHomePage()));
}

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('books').snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            return new ListTile(
              title: new Text(document['message']),
            );
          }).toList(),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  CollectionReference get messages => Firestore.instance.collection('messages');

  Future<Null> _addMessage() async {
//    Firestore.instance
//        .collection('books')
//        .document()
//        .setData(<String, String>{'message': 'Hello world!'});
    final TransactionHandler transactionHandler = (Transaction tx) async {
      print('handler on dart side');
      final DocumentSnapshot documentSnapshot = await tx
          .get(Firestore.instance.document('books/BxsUKLVDF3BLTlQO8puk'));

      await tx.update(documentSnapshot.reference, <String, dynamic>{
        'message': documentSnapshot.data['message'] + ' good'
      });
      return <String, dynamic>{'val': 1};
    };
    Firestore.instance
        .runTransaction(transactionHandler, timeout: new Duration(seconds: 10))
        .then((Map<String, dynamic> result) {
      print(result);
      print('transaction is complete');
    }).catchError((PlatformException e) {
      print('dart side error message: ' + e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firestore Example'),
      ),
      body: new BookList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
