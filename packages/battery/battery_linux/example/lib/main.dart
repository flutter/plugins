// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:battery/battery.dart';

void main() {
  runApp(MyApp());
}

/// Main app.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Battery _battery = Battery();
  BatteryState _batteryState = BatteryState.full;
  StreamSubscription<BatteryState> _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('State is : $_batteryState'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.battery_unknown),
          onPressed: () async {
            final int batteryLevel = await _battery.batteryLevel;
            // ignore: unawaited_futures
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                content: Text('Battery: $batteryLevel%'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_batteryStateSubscription != null) {
      _batteryStateSubscription.cancel();
    }
  }
}
