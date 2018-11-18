// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _connectionStatus = 'Unknown';
  String _wifiName, _wifiIP;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() => _connectionStatus = result.toString());
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    String connectionStatus;
    String wifiName;
    String wifiIp;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    try {
      wifiName = (await _connectivity.getWifiName()).toString();

      setState(() {
        _wifiName = wifiName;
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }

    try {
      wifiIp = (await _connectivity.getWifiIP()).toString();

      setState(() {
        _wifiIP = wifiIp;
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(child: Text(getConnectionText())),
    );
  }

  String getConnectionText() {
    if (_connectionStatus.contains('wifi')) {
      getWifiDetails();

      return 'Connection Status: $_connectionStatus\n'
          'Wifi Name: $_wifiName\n'
          'Wifi IP: $_wifiIP\n';
    } else {
      return 'Connection Status: $_connectionStatus\n';
    }
  }

  Future<void> getWifiDetails() async {
    String wifiName, wifiIp;

    try {
      wifiName = (await _connectivity.getWifiName()).toString();
    } on PlatformException catch (e) {
      print(e.toString());

      wifiName = "Failed to get Wifi Name";
    }

    try {
      wifiIp = (await _connectivity.getWifiIP()).toString();
    } on PlatformException catch (e) {
      print(e.toString());

      wifiName = "Failed to get Wifi IP";
    }

    setState(() {
      _wifiName = wifiName;
      _wifiIP = wifiIp;
    });
  }
}
