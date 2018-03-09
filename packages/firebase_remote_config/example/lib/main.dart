import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new MaterialApp(title: 'Firestore Example', home: new MyHomePage()));
}


class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    RemoteConfig rc;

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firestore Example'),
      ),
      body: new FutureBuilder<void>(
          future: new Future<void>(() async {
            rc = await RemoteConfig.instance;
            await rc.setConfigSettings(new RemoteConfigSettings(debugMode: false));
            await rc.setDefaults(<String, dynamic>{
              'welcome': 'default welcome'
            });
            try {
              await rc.fetch(expiration: 0);
            } on PlatformException catch(e) {
              print('Unable to fetch remote config');
              if (e.code == RemoteConfig.fetchFailedThrottled) {
                print('Fetch is currently throttled try again later.');
                print(e.message);
                print(e.details);
              }
            }
            await rc.activate();
          }),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none: return new Text('loading...');
              case ConnectionState.waiting: return new Text('waiting...');
              default:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return new Text('error');
                } else {
                  return new Text('Welcome: ${rc.getString('welcome')}');
                }
            }
          }),
    );
  }
}
