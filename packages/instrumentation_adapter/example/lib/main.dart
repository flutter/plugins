import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:instrumentation_adapter/instrumentation_adapter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Platform: ${Platform.operatingSystem}\n'),
        ),
      ),
    );
  }
}
