// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(new MaterialApp(title: 'Firestore Example', home: new MyHomePage()));
}

class MessageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('messages').snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final int messageCount = snapshot.data.documents.length;
        return new ListView.builder(
          itemCount: messageCount,
          itemBuilder: (_, int index) {
            final DocumentSnapshot document = snapshot.data.documents[index];
            return new ListTile(
              title: new Text(document['message'] ?? '<No message retrieved>'),
              subtitle: new Text('Message ${index + 1} of $messageCount'),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  CollectionReference get messages => Firestore.instance.collection('messages');

  Future<Null> _addMessage() async {
    messages.document().setData(<String, String>{'message': 'Hello world!'});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firestore Example'),
      ),
      body: new MessageList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
