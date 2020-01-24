// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sample flutter_plugin_android_lifecycle usage'),
        ),
        body: Center(
            child: Text(
                'This plugin only provides Android Lifecycle API\n for other Android plugins.')),
      ),
    );
  }
}
