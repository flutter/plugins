// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firestore/firestore.dart';
import 'package:firestore_example/book.dart';
import 'package:firestore_example/list_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(title: 'Firestore Example', home: new MyHomePage()));
}

class BookList extends StatefulWidget {
  @override
  _BookListState createState() => new _BookListState();
}

class MyHomePage extends StatelessWidget {
  CollectionReference get messages => Firestore.instance.collection('messages');

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

  Future<Null> _addMessage() async {
    final DocumentReference ref =
        Firestore.instance.collection('books').document();
    ref.setData(<String, String>{
      'message': 'Hello world!',
      'id': ref.path.split("/").last,
      // 'timestamp': ServerValue.timestamp,
    });
  }
}

class _BookListState extends State<BookList> {
  ListModel<String> _bookList;
  StreamSubscription<QuerySnapshot> _bookSub;
  final GlobalKey<AnimatedListState> _listKey =
      new GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return new AnimatedList(
      key: _listKey,
      itemBuilder: _buildItem,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bookSub.cancel();
  }

  @override
  void initState() {
    super.initState();
    _bookList = new ListModel<String>(
      listKey: _listKey,
      removedItemBuilder: _buildRemovedItem,
    );
    _bookSub = Firestore.instance
        .collection('books', parameters: <String, dynamic>{
          //"startAtId": "-KwvsbUPmlKxVPTLnYJG",
          "limit": 12,
          //"endAtId": "-Kwvs_BSnxFwXmRR-Vtb",
          "orderBy": "id",
          "descending": true,
        })
        .snapshots
        .listen((QuerySnapshot snap) {
          setState(() {
            snap.documentChanges.forEach((docChange) {
              if (docChange.type == DocumentChangeType.added) {
                _bookList.insert(
                    docChange.newIndex, docChange.document.data["id"]);
              } else if (docChange.type == DocumentChangeType.removed) {
                _bookList.removeAt(docChange.oldIndex);
              }
            });
          });
        });
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return new BookWidget(
      animation: animation,
      bookModel: _bookList[index],
    );
  }

  // Used to build an item after it has been removed from the list. This method is
  // needed because a removed item remains  visible until its animation has
  // completed (even though it's gone as far this ListModel is concerned).
  // The widget will be used by the [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
    String item,
    BuildContext context,
    Animation<double> animation,
  ) {
    return new BookWidget(
      animation: animation,
      bookModel: item,
    );
  }
}
