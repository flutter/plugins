import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String name = 'foo';
  final FirebaseOptions options = const FirebaseOptions(
    googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
    gcmSenderID: '297855924061',
    apiKey: 'AIzaSyBq6mcufFXfyqr79uELCiqM_O_1-G72PVU',
  );

  Future<Null> _configure() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: name,
      options: options,
    );
    assert(app != null);
    print('Configured $app');
  }

  Future<Null> _allApps() async {
    final List<FirebaseApp> apps = await FirebaseApp.allApps();
    print('Currently configured apps: $apps');
  }

  Future<Null> _options() async {
    final FirebaseApp app = await FirebaseApp.appNamed(name);
    final FirebaseOptions options = await app?.options;
    print('Current options for app $name: $options');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Core example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RaisedButton(
                  onPressed: _configure, child: const Text('initialize')),
              RaisedButton(onPressed: _allApps, child: const Text('allApps')),
              RaisedButton(onPressed: _options, child: const Text('options')),
            ],
          ),
        ),
      ),
    );
  }
}
