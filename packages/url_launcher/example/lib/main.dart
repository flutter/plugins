// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'URL Launcher',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'URL Launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Null> _launched;

  void _launchUrl() {
    setState(() {
      _launched = _launch('https://flutter.io');
    });
  }

  Future<Null> _launch(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<Null> snapshot) {
    if (snapshot.hasError) {
      return new Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text('https://flutter.io'),
                ),
                new ElevatedButton(
                  onPressed: _launchUrl,
                  child: const Text('Go'),
                ),
              ],
            ),
            new FutureBuilder<Null>(future: _launched, builder: _launchStatus),
          ],
        ),
      ),
    );
  }
}
