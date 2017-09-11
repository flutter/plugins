// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_firestore/firestore.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Firestore Example',
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  QuerySnapshot _messagesSnapshot;
  final CollectionReference _messagesRef = Firestore.instance
    .reference()
    .child('messages');
  StreamSubscription<Event> _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _messagesSubscription = _messagesRef.onSnapshot.listen(
      (QuerySnapshot snapshot) {
        setState(() {
          _messagesSnapshot = snapshot;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messagesSubscription.cancel();
  }

  Future<Null> _addMessage() async {
    FirebaseUser user = await FirebaseAuth.instance.signInAnonymously();
    _messagesRef.document().setData(<String, String>{
      'author': user.uid,
      'message': 'Hello world!',
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firestore Example'),
      ),
      body: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot document = _messagesSnapshot.documents[index];
          return new ListTile(
            leading: new CircleAvatar(
              child: new Text(document['author'].substring(0, 2)),
            ),
            title: new Text(document['message']),
          );
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addMessage,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
