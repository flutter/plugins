// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Firebase Auth Demo',
      home: new MyHomePage(title: 'Firebase Auth Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> _message = new Future<String>.value('');
  TextEditingController _mobilenumbercontroller = new TextEditingController();
  TextEditingController _otpcontroller = new TextEditingController();



  Future<String> _testSignInAnonymously() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInAnonymously succeeded: $user';
  }

 Future<String> _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }
void alert(String msg){
  showDialog<String>(
    context: context,
    child: new AlertDialog(content: new Text(msg), actions: <Widget>[
      new FlatButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          }),
    ]),
  );
}
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new MaterialButton(
              child: const Text('Test signInAnonymously'),
              onPressed: () {
                setState(() {
                  _message = _testSignInAnonymously();
                });
              }),

          new MaterialButton(
              child: const Text('Test signInWithGoogle'),
              onPressed: () {
                setState(() {
                  _message = _testSignInWithGoogle();
                });
              }),




new Container(height: 20.0,),
        new Container(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
          child:new TextFormField(
            controller: _mobilenumbercontroller,
            decoration: const InputDecoration(
              hintText: 'Enter mobilenumber to get otp',

              helperStyle: const TextStyle(
                  color: Colors.grey, fontSize: 11.0),
            ),
            keyboardType: TextInputType.phone,

          ),
        ),
         new Center(child:new RaisedButton(
              child: const Text('send otp'),
              onPressed: () async{
                try {
                  var request = await _auth.signInWithPhoneNumber(
                      phoneNumber: _mobilenumbercontroller.text

                  );
                  alert("$request to requested mobile number");

                }catch(exception){
                alert(exception.toString());
                }
              }),),
          new Container(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, top: 0.0, bottom: 0.0),
            child:new TextFormField(
                controller: _otpcontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter otp',

                  helperStyle: const TextStyle(
                      color: Colors.grey, fontSize: 11.0),
                ),
                keyboardType: TextInputType.number,

            ),
          ),
          new Container(height:20.0),
         new Center(child: new RaisedButton(
              child: const Text('verify otp'),
              onPressed: () async{
                try {
                var user =  await _auth.verifyotp(
                      otp: _otpcontroller.text
                  );
                alert("user created with this uid: ${user.uid}");
                }catch(exception){
                alert(exception.toString());
                }

              }),),
          new FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return new Text(snapshot.data ?? '',
                    style: const TextStyle(
                        color: const Color.fromARGB(255, 0, 155, 0)));
              }),
        ],
      ),
    );
  }

}
