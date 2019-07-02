import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_inappmessaging/firebase_inappmessaging.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  showSnackBar(BuildContext context, String text) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('In-App Messaging example'),
      ),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AnalyticsEventExample(),
              ProgrammaticTriggersExample(),
            ],
          ),
        );
      }),
    ));
  }
}

class ProgrammaticTriggersExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Text(
              "Programmatic Trigger",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text("Manually trigger events programmatically "),
            SizedBox(height: 8),
            RaisedButton(
              onPressed: () async {
                await FirebaseInAppMessaging.triggerEvent('chicken_event');
                const text = "Triggering event: chicken_event";
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(text)));
              },
              color: Colors.blue,
              child: Text(
                "Programmatic Triggers".toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AnalyticsEventExample extends StatelessWidget {
  Future<void> _sendAnalyticsEvent() async {
    await MyApp.analytics
        .logEvent(name: 'awesome_event', parameters: <String, dynamic>{
      'int': 42, // not required?
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Text(
              "Log an analytics event",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text("Trigger an analytics event"),
            SizedBox(height: 8),
            RaisedButton(
              onPressed: () {
                _sendAnalyticsEvent();
                const text = "Firing analytics event: awesome_event";
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(text)));
              },
              color: Colors.blue,
              child: Text(
                "Log event".toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
