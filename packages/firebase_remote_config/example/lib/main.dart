import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_remote_config/remote_config.dart';

void main() {
  runApp(new MaterialApp(title: 'Firestore Example', home: new MyHomePage()));
}


class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final RemoteConfig rc = RemoteConfig.instance;
    rc.debugMode = true;

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firestore Example'),
      ),
      body: new FutureBuilder<Map<String, dynamic>>(
          future: new Future<Map<String, dynamic>>(() async {
            rc.setDefaults(<String, dynamic>{
              'welcome': 'default welcome'
            });
            return rc.fetch();
          }),
          builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
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
