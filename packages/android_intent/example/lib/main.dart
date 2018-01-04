// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      routes: <String, WidgetBuilder>{
        ExplicitIntentsWidget.routeName: (BuildContext context) =>
            const ExplicitIntentsWidget()
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  void _createAlarm() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'android.intent.action.SET_ALARM',
      arguments: const <String, dynamic>{
        'android.intent.extra.alarm.DAYS': const <int>[2, 3, 4, 5, 6],
        'android.intent.extra.alarm.HOUR': 21,
        'android.intent.extra.alarm.MINUTES': 30,
        'android.intent.extra.alarm.SKIP_UI': true,
        'android.intent.extra.alarm.MESSAGE': 'Create a Flutter app',
      },
    );
    intent.launch();
  }

  void _openExplicitIntentsView(BuildContext context) {
    Navigator.of(context).pushNamed(ExplicitIntentsWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (const LocalPlatform().isAndroid) {
      body = new Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new RaisedButton(
              child: const Text(
                  'Tap here to set an alarm\non weekdays at 9:30pm.'),
              onPressed: _createAlarm,
            ),
            new RaisedButton(
                child: const Text('Tap here to test explicit intents.'),
                onPressed: () => _openExplicitIntentsView(context)),
          ],
        ),
      );
    } else {
      body = const Text('This plugin only works with Android');
    }
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Plugin example app'),
      ),
      body: new Center(child: body),
    );
  }
}

class ExplicitIntentsWidget extends StatelessWidget {
  static const String routeName = "/explicitIntents";

  const ExplicitIntentsWidget();

  void _openGoogleMapsStreetView() {
    final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.streetview:cbll=46.414382,10.013988'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _displayMapInGoogleMaps({int zoomLevel: 12}) {
    final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('geo:37.7749,-122.4194?z=$zoomLevel'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _launchTurnByTurnNavigationInGoogleMaps() {
    final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
            'google.navigation:q=Taronga+Zoo,+Sydney+Australia&avoid=tf'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _openLinkInGoogleChrome() {
    final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.io'),
        package: 'com.android.chrome');
    intent.launch();
  }

  void _testExplicitIntentFallback() {
    final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.io'),
        package: 'com.android.chrome.implicit.fallback');
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Test explicit intents'),
      ),
      body: new Center(
        child: new Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new RaisedButton(
                child: const Text(
                    'Tap here to display panorama\nimagery in Google Street View.'),
                onPressed: _openGoogleMapsStreetView,
              ),
              new RaisedButton(
                child: const Text('Tap here to display\na map in Google Maps.'),
                onPressed: _displayMapInGoogleMaps,
              ),
              new RaisedButton(
                child: const Text(
                    'Tap here to launch turn-by-turn\nnavigation in Google Maps.'),
                onPressed: _launchTurnByTurnNavigationInGoogleMaps,
              ),
              new RaisedButton(
                child: const Text('Tap here to open link in Google Chrome.'),
                onPressed: _openLinkInGoogleChrome,
              ),
              new RaisedButton(
                child: const Text(
                    'Tap here to test explicit intent fallback to implicit.'),
                onPressed: _testExplicitIntentFallback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
