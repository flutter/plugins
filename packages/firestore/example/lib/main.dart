// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_firestore/firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(new MaterialApp(title: 'Firestore Example', home: new MyHomePage()));
}

final GoogleSignIn googleSignIn = new GoogleSignIn();

class MyHomePage extends StatelessWidget {
  CollectionReference get messages => Firestore.instance.collection('messages');

  Future<Null> _addMessage() async {
    final GoogleSignInAccount account = await googleSignIn.signIn();
    if (account == null)
      return;
    FirebaseUser user = await FirebaseAuth.instance.signInAnonymously();
    await Firestore.instance.document("users/${user.uid}").setData({
      'photoUrl': account.photoUrl,
    });
    await messages.document().setData(<String, String>{
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
      body: new StreamBuilder(
        stream: messages.snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return new Center(child: new Text('Loading...'));
          final List<DocumentSnapshot> documents = snapshot.data.documents;
          return new ListView.builder(
            reverse: true,
            itemBuilder: (BuildContext context, int index) {
              if (index >= documents.length)
                return null;
              final DocumentSnapshot document = documents[documents.length - index - 1];
              final String author = document['author'];
              return new ListTile(
                leading: new StreamBuilder(
                  stream: Firestore.instance.document("users/$author").snapshots,
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> user) {
                    Map<String, String> data = user.data?.data;
                    if (data == null)
                      return new CircleAvatar();
                    return new CircleAvatar(
                      backgroundImage: new NetworkImage(user.data.data['photoUrl']),
                    );
                  },
                ),
                title: new Text(document['message']),
              );
            },
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
