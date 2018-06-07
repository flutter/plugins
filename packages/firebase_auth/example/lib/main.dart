// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

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
      home: const MyHomePage(title: 'Firebase Auth Demo'),
      routes: <String, WidgetBuilder>{
        '/signInWithPhoneNumber': (BuildContext context) =>
            const PhoneNumberSignInPage(title: 'Sign in with phone number')
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> _message = new Future<String>.value('');

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
          new MaterialButton(
              child: const Text('Test signInWithPhoneNumber'),
              onPressed: () {
                Navigator.of(context).pushNamed("/signInWithPhoneNumber");
              }),
          new FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return new Text(
                  snapshot.data ?? '',
                  style: const TextStyle(
                    color: const Color.fromARGB(255, 0, 155, 0),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class PhoneNumberSignInPage extends StatefulWidget {
  const PhoneNumberSignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PhoneNumberSignInPageState createState() =>
      new _PhoneNumberSignInPageState();
}

class _PhoneNumberSignInPageState extends State<PhoneNumberSignInPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _phoneNumberFormKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _verificationCodeFormKey =
      new GlobalKey<FormState>();
  bool _autoValidatePhoneNumberForm = false;
  bool _autoValidateVerificationCodeForm = false;

  Future<String> _message = new Future<String>.value('');
  String _phoneNumber;
  String _verificationCode;

  StreamSubscription<PhoneSignInEvent> _phoneSignInEventSubscription;

  @override
  void initState() {
    super.initState();
    _phoneSignInEventSubscription =
        _auth.onPhoneSignInEvents.listen((PhoneSignInEvent phoneSignInEvent) {
      switch (phoneSignInEvent) {
        case PhoneSignInEvent.CODE_SENT:
          print("[UI] Code sent event - Display view to let the user enter it");
          break;

        case PhoneSignInEvent.CODE_AUTO_RETRIEVAL_TIMEOUT:
          print("[UI] Code auto retrieval timeout event");
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_phoneSignInEventSubscription != null) {
      _phoneSignInEventSubscription.cancel();
    }
  }

  Future<String> _testSignInWithPhoneNumber(String phoneNumber) async {
    try {
      final FirebaseUser user =
          await _auth.signInWithPhoneNumber(phoneNumber: phoneNumber);

      assert(!user.isEmailVerified);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      return 'signInWithPhoneNumber succeeded: $user';
    } on PlatformException catch (e) {
      return _handlePhoneSignInError(e);
    }
  }

  Future<String> _testVerifyPhoneNumber(String code) async {
    try {
      final FirebaseUser user = await _auth.verifyPhoneNumber(code: code);

      assert(!user.isEmailVerified);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      return 'verifyPhoneNumber succeeded: $user';
    } on PlatformException catch (e) {
      return _handlePhoneSignInError(e);
    }
  }

  Future<String> _testResendVerificationCode(String phoneNumber) async {
    try {
      final FirebaseUser user =
          await _auth.resendVerificationCode(phoneNumber: phoneNumber);

      assert(!user.isEmailVerified);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      return 'resendVerificationCode succeeded: $user';
    } on PlatformException catch (e) {
      return _handlePhoneSignInError(e);
    }
  }

  Future<String> _handlePhoneSignInError(PlatformException e) {
    final PhoneSignInError phoneSignInError =
        stringToPhoneSignInErrorEnum(e.code);

    switch (phoneSignInError) {
      case PhoneSignInError.NO_FOREGROUND_ACTIVITY:
        print("[handlePhoneSignInError] No foreground activity\n${e.message}");
        break;

      case PhoneSignInError.INVALID_REQUEST:
        print("[handlePhoneSignInError] Invalid request\n${e.message}");
        break;

      case PhoneSignInError.SMS_QUOTA_EXCEEDED:
        print("[handlePhoneSignInError] SMS quota exceeded\n${e.message}");
        break;

      case PhoneSignInError.UNAUTHORIZED:
        print("[handlePhoneSignInError] Unauthorized\n${e.message}");
        break;

      case PhoneSignInError.API_NOT_AVAILABLE:
        print("[handlePhoneSignInError] API not available\n${e.message}");
        break;
    }

    return new Future<String>.value(e.message);
  }

  void _closeKeyBoard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  String _validatePhoneNumber(String phoneNumber) {
    final RegExp phoneExp = new RegExp(r'^[\d -+(),.*#]+$');
    if (!phoneExp.hasMatch(phoneNumber))
      return 'Please enter a valid phone number.';
    return null;
  }

  String _validateVerificationCode(String verificationCode) {
    final RegExp phoneExp = new RegExp(r'^\d{6}$');
    if (!phoneExp.hasMatch(verificationCode))
      return 'Please enter a valid verification code.';
    return null;
  }

  void _handlePhoneNumberSubmitted() {
    final FormState form = _phoneNumberFormKey.currentState;
    if (!form.validate()) {
      _autoValidatePhoneNumberForm = true;
      _showInSnackBar('Invalid phone number!');
    } else {
      form.save();
      _closeKeyBoard();
      _showInSnackBar('Phone number: $_phoneNumber');
    }
  }

  void _handlePhoneNumberSaved(String phoneNumber) {
    _phoneNumber = phoneNumber;
    setState(() {
      _message = _testSignInWithPhoneNumber(_phoneNumber);
    });
  }

  void _handleVerificationCodeSubmitted() {
    final FormState form = _verificationCodeFormKey.currentState;
    if (!form.validate()) {
      _autoValidateVerificationCodeForm = true;
      _showInSnackBar('Invalid verification code!');
    } else {
      form.save();
      _closeKeyBoard();
      _showInSnackBar('Verification code: $_verificationCode');
    }
  }

  void _handleVerificationCodeSaved(String verificationCode) {
    _verificationCode = verificationCode;
    setState(() {
      _message = _testVerifyPhoneNumber(_verificationCode);
    });
  }

  void _handleResendVerificationCode() {
    if (_phoneNumber == null || _phoneNumber == '') {
      _showInSnackBar('Please signInWithPhoneNumber first!');
      return;
    }

    setState(() {
      _message = _testResendVerificationCode(_phoneNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Center(
              child: new Text("Step 1",
                  style: Theme.of(context).textTheme.headline),
            ),
            new Container(
              height: 150.0,
              child: new Form(
                key: _phoneNumberFormKey,
                autovalidate: _autoValidatePhoneNumberForm,
                child: new ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: <Widget>[
                    new TextFormField(
                      initialValue: _phoneNumber ?? '',
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.phone),
                        hintText:
                            'Phone number with country calling code prefix',
                        labelText: 'Phone Number *',
                      ),
                      keyboardType: TextInputType.phone,
                      onSaved: _handlePhoneNumberSaved,
                      validator: _validatePhoneNumber,
                    ),
                    new Container(
                      padding: const EdgeInsets.all(20.0),
                      alignment: Alignment.center,
                      child: new Column(
                        children: <Widget>[
                          new RaisedButton(
                            child: const Text('Test signInWithPhoneNumber'),
                            onPressed: _handlePhoneNumberSubmitted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            new Center(
                child: new Text(
              "Step 2",
              style: Theme.of(context).textTheme.headline,
            )),
            new Expanded(
              child: new Form(
                key: _verificationCodeFormKey,
                autovalidate: _autoValidateVerificationCodeForm,
                child: new ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: <Widget>[
                    new TextFormField(
                      initialValue: _verificationCode ?? '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                      ),
                      maxLines: 1,
                      onSaved: _handleVerificationCodeSaved,
                      validator: _validateVerificationCode,
                    ),
                    new Container(
                      height: 150.0,
                      padding: const EdgeInsets.only(top: 5.0),
                      alignment: Alignment.center,
                      child: new Column(
                        children: <Widget>[
                          new RaisedButton(
                            child: const Text('Test verifyPhoneNumber'),
                            onPressed: _handleVerificationCodeSubmitted,
                          ),
                          const SizedBox(height: 10.0),
                          new RaisedButton(
                            child: const Text('Test resendVerificationCode'),
                            onPressed: _handleResendVerificationCode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            new Expanded(
              child: new FutureBuilder<String>(
                future: _message,
                builder: (_, AsyncSnapshot<String> snapshot) {
                  return new Text(
                    snapshot.data ?? '',
                    style: const TextStyle(
                      color: const Color.fromARGB(255, 0, 155, 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
