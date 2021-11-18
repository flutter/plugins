// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

void main() {
  runApp(MyApp());
}

/// A sample app for launching intents.
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: <String, WidgetBuilder>{
        ExplicitIntentsWidget.routeName: (BuildContext context) =>
            const ExplicitIntentsWidget()
      },
    );
  }
}

/// Holds the different intent widgets.
class MyHomePage extends StatelessWidget {
  void _createAlarm() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'android.intent.action.SET_ALARM',
      arguments: <String, dynamic>{
        'android.intent.extra.alarm.DAYS': <int>[2, 3, 4, 5, 6],
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
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              child: const Text(
                  'Tap here to set an alarm\non weekdays at 9:30pm.'),
              onPressed: _createAlarm,
            ),
            ElevatedButton(
                child: const Text('Tap here to test explicit intents.'),
                onPressed: () => _openExplicitIntentsView(context)),
          ],
        ),
      );
    } else {
      body = const Text('This plugin only works with Android');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(child: body),
    );
  }
}

/// Launches intents to specific Android activities.
class ExplicitIntentsWidget extends StatelessWidget {
  const ExplicitIntentsWidget(); // ignore: public_member_api_docs

  // ignore: public_member_api_docs
  static const String routeName = "/explicitIntents";

  void _openGoogleMapsStreetView() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.streetview:cbll=46.414382,10.013988'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _displayMapInGoogleMaps({int zoomLevel = 12}) {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('geo:37.7749,-122.4194?z=$zoomLevel'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _launchTurnByTurnNavigationInGoogleMaps() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
            'google.navigation:q=Taronga+Zoo,+Sydney+Australia&avoid=tf'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _openLinkInGoogleChrome() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.io'),
        package: 'com.android.chrome');
    intent.launch();
  }

  void _startActivityInNewTask() {
    final AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('https://flutter.io'),
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  void _testExplicitIntentFallback() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.io'),
        package: 'com.android.chrome.implicit.fallback');
    intent.launch();
  }

  void _openLocationSettingsConfiguration() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'action_location_source_settings',
    );
    intent.launch();
  }

  void _openApplicationDetails() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'action_application_details_settings',
      data: 'package:io.flutter.plugins.androidintentexample',
    );
    intent.launch();
  }

  void _openMP4() {
    final AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: 'https://stream.voidboost.cc/19edf3fef04ae30757e30374916038e8:2021111914:dnJKSzRqT2xxbkU1OEozUW90aFhVd0Q2WGRFa3kzanBPL3BWU2dyV1IzSkM4NmIway9BNC9JaTJFa09iSWlsY3pIazJFN0EzOHZzNmdncW9Gdmp1M1E9PQ==/4/1/2/6/5/3/c4a3u.mp4',
      arguments: {'subs': ['https://static.voidboost.com/view/1U36mRD5OHOSgAdakIi9Tw/1637321905/4/1/2/6/5/3/yozfijgc8dra.vtt',
        'https://static.voidboost.com/view/sFTUEhk09PPIYLAwQKQVjw/1637321905/4/1/2/6/5/3/uv8o3w19gm.vtt']},
      // arguments: {'subs': []},
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test explicit intents'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: const Text(
                    'Tap here to play mp4 with subtitles'),
                onPressed: _openMP4,
              ),
              ElevatedButton(
                child: const Text(
                    'Tap here to display panorama\nimagery in Google Street View.'),
                onPressed: _openGoogleMapsStreetView,
              ),
              ElevatedButton(
                child: const Text('Tap here to display\na map in Google Maps.'),
                onPressed: _displayMapInGoogleMaps,
              ),
              ElevatedButton(
                child: const Text(
                    'Tap here to launch turn-by-turn\nnavigation in Google Maps.'),
                onPressed: _launchTurnByTurnNavigationInGoogleMaps,
              ),
              ElevatedButton(
                child: const Text('Tap here to open link in Google Chrome.'),
                onPressed: _openLinkInGoogleChrome,
              ),
              ElevatedButton(
                child: const Text('Tap here to start activity in new task.'),
                onPressed: _startActivityInNewTask,
              ),
              ElevatedButton(
                child: const Text(
                    'Tap here to test explicit intent fallback to implicit.'),
                onPressed: _testExplicitIntentFallback,
              ),
              ElevatedButton(
                child: const Text(
                  'Tap here to open Location Settings Configuration',
                ),
                onPressed: _openLocationSettingsConfiguration,
              ),
              ElevatedButton(
                child: const Text(
                  'Tap here to open Application Details',
                ),
                onPressed: _openApplicationDetails,
              )
            ],
          ),
        ),
      ),
    );
  }
}
