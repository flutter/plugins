// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _authorized = 'Not Authorized';
  String _supported = 'Checking...';

  Future<Null> _authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          showDialog: false,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
  }

  Future<Null> _checkBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool supported = false;
    String message = "";
    try {
      supported = await auth.biometricsSupported();
    } on PlatformException catch (e) {
      print(e);
    } on Exception catch (e) {
      message = e.toString();
    }
    if (!mounted) return;

    setState(() {
      _supported = supported ? 'Supported' : 'Not Supported: ' + message;
    });
  }

  @override
  void initState() {
    _checkBiometrics();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Biometrics: $_supported\n'),
                Text('Current State: $_authorized\n'),
                RaisedButton(
                  child: const Text('Authenticate'),
                  onPressed: _authenticate,
                )
              ])),
    ));
  }
}
