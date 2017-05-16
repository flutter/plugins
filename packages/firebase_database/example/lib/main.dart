import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Database Example',
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

const String kTestString = "Hello world!";

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final DatabaseReference _reference = FirebaseDatabase.instance.reference();
  StreamSubscription _childAdded;

  String _kTestKey = 'Hello';
  String _kTestValue = 'world!';

  @override
  void initState() {
    super.initState();
    _childAdded = _reference.onChildAdded.listen((Event event) {
      assert(event.snapshot.value[_kTestKey] == _kTestValue);
      print("Child added: ${event.snapshot.value}");
      setState(() {
        _counter++;
      });
    });
  }

  @override dispose() {
    super.dispose();
    _childAdded.cancel();
  }

  _increment() async {
    await FirebaseAuth.instance.signInAnonymously();
    _reference.push().set({ _kTestKey: _kTestValue });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter Database Example'),
      ),
      body: new Center(
        child: new Text(
          'Button tapped $_counter time${ _counter == 1 ? '' : 's' }.\n\n'
          'This includes all devices, ever.',
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _increment,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
