import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'SharedPreferences Demo',
      home: new SharedPreferencesDemo(),
    );
  }
}

class SharedPreferencesDemo extends StatefulWidget {
  SharedPreferencesDemo({ Key key }) : super(key: key);

  @override
  SharedPreferencesDemoState createState() => new SharedPreferencesDemoState();
}

class SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> _incrementCounter() async {
    SharedPreferences prefs = await _prefs;
    int counter = (prefs.getInt('counter') ?? 0) + 1;
    setState(() {
      prefs.setInt("counter", counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("SharedPreferences Demo"),
      ),
      body: new Center(
        child: new FutureBuilder(
          future: _prefs,
          builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return new Text('Loading...');
            int counter = snapshot.requireData.getInt('counter') ?? 0;
            return new Text(
              'Button tapped $counter time${ counter == 1 ? '' : 's' }.\n\n'
              'This should persist across restarts.',
            );
          }
        )
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
