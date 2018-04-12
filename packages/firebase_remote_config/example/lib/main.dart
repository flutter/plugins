import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
      title: 'Remote Config Example',
      home: new FutureBuilder<RemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
          return snapshot.hasData
              ? new WelcomeWidget(remoteConfig: snapshot.data)
              : new Container();
        },
      )));
}

class WelcomeWidget extends AnimatedWidget {
  WelcomeWidget({this.remoteConfig}) : super(listenable: remoteConfig);

  final RemoteConfig remoteConfig;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: new Center(
          child: new Text('Welcome ${remoteConfig.getString('welcome')}')),
      floatingActionButton: new FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () async {
            try {
              // Using default duration to force fetching from remote server.
              await remoteConfig.fetch(expiration: const Duration(seconds: 0));
              await remoteConfig.activateFetched();
            } on FetchThrottledException catch (exception) {
              // Fetch throttled.
              print(exception);
            } catch (exception) {
              print(
                  'Unable to fetch remote config. Cached or default values will be '
                  'used');
            }
          }),
    );
  }
}

Future<RemoteConfig> setupRemoteConfig() async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  // Enable developer mode to relax fetch throttling
  remoteConfig.setConfigSettings(new RemoteConfigSettings(debugMode: true));
  remoteConfig.setDefaults(<String, dynamic>{
    'welcome': 'default welcome',
    'hello': 'default hello',
  });
  return remoteConfig;
}
