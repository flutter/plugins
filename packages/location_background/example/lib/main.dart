// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file

import 'dart:isolate';
import 'dart:ui' hide TextStyle;

import 'package:flutter/material.dart';
import 'package:location_background_plugin/location_background_plugin.dart';

import 'background.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  ReceivePort _foregroundPort = ReceivePort();
  LocationBackgroundPlugin _locationPlugin;
  Location _lastLocation;
  bool _isTracking = false;

  @override
  void initState() {
    _lastLocation = Location(-1.0, 0.0, 0.0, -1.0, -1.0);
    super.initState();
    initPlatformState();
  }

  void initPlatformState() {
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
    _foregroundPort.listen((dynamic message) {
      final Location location = Location.fromJson(message);
      print('UI Location: $location');
      setState(() {
        _lastLocation = location;
      });
    }, onDone: () {
      // Remove the port mapping just in case the UI is shutting down but
      // background isolate is continuing to run.
      IsolateNameServer.removePortNameMapping(kLocationPluginPortName);
    });
    _locationPlugin ??= LocationBackgroundPlugin();
  }

  String _padZero2(int i) => i.toString().padLeft(2, '0');

  String _formatTime(DateTime t) {
    t = t.toLocal();
    final int hour = t.hour;
    final String minute = _padZero2(t.minute);
    final String second = _padZero2(t.second);
    final int year = t.year;
    return '$hour:$minute:$second $year';
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle boldText = TextStyle(fontWeight: FontWeight.bold);
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Background Plugin Demo'),
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
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
                        await _locationPlugin.monitorSignificantLocationChanges(
                            LocationMonitor.locationCallback);
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
