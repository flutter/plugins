// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file

import 'package:flutter/material.dart';
import 'package:location_background_plugin/location_background_plugin.dart';

import 'dart:isolate';
import 'dart:ui';

import 'background.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() {
    return new _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  ReceivePort _foregroundPort = new ReceivePort();
  LocationBackgroundPlugin _locationPlugin;
  Location _lastLocation;
  bool _isTracking = false;
  static const boldText = TextStyle(fontWeight: FontWeight.bold);

  @override
  initState() {
    _lastLocation = new Location(-1.0, 0.0, 0.0, -1.0, -1.0);
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    // The IsolateNameServer allows for us to create a mapping between a String
    // and a SendPort that is managed by the Flutter engine. A SendPort can
    // then be looked up elsewhere, like a background callback, to establish
    // communication channels between isolates that were not spawned by one
    // another.
    if (!IsolateNameServer.registerPortWithName(
        _foregroundPort.sendPort, kLocationPluginPortName)) {
      throw 'Unable to register port!';
    }

    // Listen on the port for location updates from our background callback.
    _foregroundPort.listen((message) {
      final location = new Location.fromJson(message);
      print('UI Location: $location');
      setState(() {
        _lastLocation = location;
      });
    });
    _locationPlugin ??= new LocationBackgroundPlugin();
  }

  String _padZero2(int i) => i.toString().padLeft(2, '0');

  String _formatTime(DateTime t) {
    t = t.toLocal();
    final hour = t.hour;
    final minute = _padZero2(t.minute);
    final second = _padZero2(t.second);
    final year = t.year;
    return '$hour:$minute:$second $year';
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text('Background Plugin Demo'),
            ),
            body: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                      child: Text(
                    'Update Time:',
                    style: boldText,
                  )),
                  Center(child: Text('${_formatTime(_lastLocation.time)}')),
                  const Center(
                      child: Text(
                    'Location:',
                    style: boldText,
                  )),
                  Center(
                      child: Text(
                          '(${_lastLocation.latitude}, ${_lastLocation.longitude})')),
                  const Center(
                      child: Text(
                    'Altitude:',
                    style: boldText,
                  )),
                  Center(child: Text('${_lastLocation.altitude} m')),
                  const Center(
                      child: Text(
                    'Speed (meters per second)',
                    style: boldText,
                  )),
                  Center(child: Text('${_lastLocation.speed} m/s')),
                  Center(
                      child: RaisedButton(
                    child:
                        Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                    onPressed: () async {
                      if (!_isTracking) {
                        await _locationPlugin
                            .monitorLocationChanges(Foo.locationCallback);
                      } else {
                        await _locationPlugin.cancelLocationUpdates();
                      }
                      setState(() {
                        _isTracking = !_isTracking;
                      });
                    },
                  ))
                ])));
  }
}
