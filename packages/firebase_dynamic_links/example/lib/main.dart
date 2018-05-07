import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> _getDynamicLink() async {
    final DynamicLinkComponents components = new DynamicLinkComponents(
        domain: "cx4k7.app.goo.gl", link: Uri.parse("https://google.com"));

    final AndroidParameters androidParameters = new AndroidParameters(
        packageName: "io.flutter.plugins.firebasedynamiclinksexample");
    components.androidParameters = androidParameters;

    final Uri uri = await components.uri;
    print(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(
              onPressed: _getDynamicLink, child: const Text("Create Link")),
        ),
      ),
    );
  }
}
