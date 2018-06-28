// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _authorized = 'Not Authorized';
  List<String> _options = <String>[];

  @override
  void initState() {
    super.initState();

    _getBiometricOptions();
  }

  Future<Null> _authenticate() async {
    final LocalAuthentication auth = new LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
  }

  Future<Null> _getBiometricOptions() async {
    final LocalAuthentication auth = new LocalAuthentication();
    final List<Biometric> options = await auth.getBiometricOptions();
    final List<String> stringOptions = <String>[];

    for (Biometric b in options) {
      switch (b) {
        case Biometric.face:
          stringOptions.add('face');
          break;

        case Biometric.fingerprint:
          stringOptions.add('fingerprint');
          break;

        default:
          stringOptions.add('other');
          break;
      }
    }

    setState(() => _options = stringOptions);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
      appBar: new AppBar(
        title: const Text('Plugin example app'),
      ),
      body: new ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Text('Available biometrics: ${_options.toString()}\n'),
                new Text('Current State: $_authorized\n'),
                new RaisedButton(
                  child: const Text('Authenticate'),
                  onPressed: _authenticate,
                )
              ])),
    ));
  }
}
