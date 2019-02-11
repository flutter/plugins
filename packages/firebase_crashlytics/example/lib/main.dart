import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  // Set reportInDevMode to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It should not intended to be used in production.
  Crashlytics.instance.reportInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Crashlytics example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              FlatButton(
                  child: const Text('Key'),
                  onPressed: () {
                    Crashlytics.instance.setString('iaw', 'i am working');
                  }),
              FlatButton(
                  child: const Text('log'),
                  onPressed: () {
                    for (int i = 0; i < 10000; i++) {
                      Crashlytics.instance.log(
                          'i am working well ${DateTime.now().millisecondsSinceEpoch}');
                    }
                  }),
              FlatButton(
                  child: const Text('Crash'),
                  onPressed: () {
                    // Throw an error that will be sent to Crashlytics.
                    Crashlytics.instance.crash();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
