import 'package:flutter/material.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

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
                    Crashlytics.instance.setString('foo', 'bar');
                  }),
              FlatButton(
                  child: const Text('Log'),
                  onPressed: () {
                    Crashlytics.instance.log('baz');
                  }),
              FlatButton(
                  child: const Text('Crash'),
                  onPressed: () {
                    // Use Crashlytics to throw an error. Use this for
                    // confirmation that errors are being correctly reported.
                    Crashlytics.instance.crash();
                  }),
              FlatButton(
                  child: const Text('Throw Error'),
                  onPressed: () {
                    // Example of thrown error, it will be caught and sent to
                    // Crashlytics.
                    throw StateError('Uncaught error thrown by app.');
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
