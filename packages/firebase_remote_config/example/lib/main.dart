import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new MaterialApp(
    title: 'Remote Config Example',
    home: new MyHomePage()
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyHomePageState();
  }
}


class MyHomePageState extends State<MyHomePage> {
  RemoteConfig rc;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Remote Config Example'),
      ),
      body: new FutureBuilder<void>(
          future: setupRemoteConfig(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none:
                return new Center(
                  child:  new Text('loading...'),
                );
              case ConnectionState.waiting:
                return new Center(
                  child:  new Text('waiting...'),
                );
              default:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return new Center(
                    child:  new Text('Failed to show welcome message'),
                  );
                } else {
                  return new Center(
                    child:  new Text('Welcome: ${rc.getString('welcome')}'),
                  );
                }
            }
          }),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.refresh),
          onPressed: () {
            setState(() {});
          }),
    );
  }

  Future<void> setupRemoteConfig() async {
    if (rc == null) {
      // Get remote config instance
      rc = await RemoteConfig.instance;
      // Enable developer mode to relax fetch throttling
      await rc.setConfigSettings(new RemoteConfigSettings(debugMode: true));
      await rc.setDefaults(<String, dynamic>{
        'welcome': 'default welcome'
      });
    }
    try {
      await rc.fetch(expiration: 0);
    } on FetchThrottledException catch(fetchThrottledException) {
      print(fetchThrottledException);
      // Get the DateTime for when another fetch is possible with:
      // fetchThrottledException.throttleEnd
    } catch(exception) {
      print('Unable to fetch remote config. Will use cached, default or static values');
    }
    // Activate the values fetched from remote server.
    await rc.activateFetched();
    return new Future<void>.value();
  }
}
