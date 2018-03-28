import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
      title: 'Remote Config Example',
      home: new FutureBuilder<RemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new ConnectionStateWidget(stateMessage: 'Loading...');
            case ConnectionState.waiting:
              return new ConnectionStateWidget(stateMessage: 'Waiting...');
            default:
              if (snapshot.hasError || snapshot.data == null) {
                print(snapshot.error);
                return new ConnectionStateWidget(
                  stateMessage: 'Unable to fetch remote config.',
                );
              }
              return new WelcomeWidget(remoteConfig: snapshot.data);
          }
        },
      )));
}

class WelcomeWidget extends AnimatedWidget {
  final RemoteConfig remoteConfig;

  WelcomeWidget({this.remoteConfig}) : super(listenable: remoteConfig);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: new Center(
          child: new Text('Welcome ${remoteConfig.getString('welcome')}')),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.refresh),
          onPressed: () {
            retrieveConfig(remoteConfig: remoteConfig);
          }),
    );
  }
}

class ConnectionStateWidget extends StatelessWidget {
  final String stateMessage;

  ConnectionStateWidget({this.stateMessage});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: new Center(child: new Text(stateMessage)),
    );
  }
}

Future<RemoteConfig> setupRemoteConfig() async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  // Enable developer mode to relax fetch throttling
  remoteConfig.setConfigSettings(new RemoteConfigSettings(debugMode: true));
  await remoteConfig.setDefaults(<String, dynamic>{
    'welcome': 'default welcome',
    'hello': 'default hello',
  });
  await retrieveConfig(remoteConfig: remoteConfig);
  return remoteConfig;
}

Future<void> retrieveConfig({RemoteConfig remoteConfig}) async {
  try {
    // Using default duration to force fetching from remote server.
    await remoteConfig.fetch(expiration: const Duration());
    await remoteConfig.activateFetched();
  } on FetchThrottledException catch (exception) {
    print(exception);
    print(remoteConfig.getValue('welcome').source);
  } catch (exception) {
    print('Unable to fetch remote config.');
  }
}
