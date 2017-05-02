// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Path Provider',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Path Provider'),
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
  Future<Directory> _tempDirectory;
  Future<Directory> _appDocumentsDirectory;

  void _requestTempDirectory() {
    setState(() {
      _tempDirectory = getTemporaryDirectory();
    });
  }

  Widget _buildTempDirectory(
      BuildContext context, AsyncSnapshot<Directory> snapshot) {
    if (snapshot.hasError) {
      return new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Text('Error: ${snapshot.error}'));
    } else if (snapshot.hasData) {
      return new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Text('path: ${snapshot.data.path}'));
    } else {
      return new Padding(
          padding: const EdgeInsets.all(16.0), child: new Text(''));
    }
  }

  void _requestAppDocumentsDirectory() {
    setState(() {
      _appDocumentsDirectory = getApplicationDocumentsDirectory();
    });
  }

  Widget _buildAppDocumentsDirectory(
      BuildContext context, AsyncSnapshot<Directory> snapshot) {
    if (snapshot.hasError) {
      return new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Text('Error: ${snapshot.error}'));
    } else if (snapshot.hasData) {
      return new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Text('path: ${snapshot.data.path}'));
    } else {
      return new Padding(
          padding: const EdgeInsets.all(16.0), child: new Text(''));
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new RaisedButton(
                    child: const Text('Get Temporary Directory'),
                    onPressed: _requestTempDirectory,
                  ),
                ),
              ],
            ),
            new Expanded(
              child: new FutureBuilder<Directory>(
                  future: _tempDirectory, builder: _buildTempDirectory),
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new RaisedButton(
                    child: const Text('Get Application Documents Directory'),
                    onPressed: _requestAppDocumentsDirectory,
                  ),
                ),
              ],
            ),
            new Expanded(
              child: new FutureBuilder<Directory>(
                  future: _appDocumentsDirectory,
                  builder: _buildAppDocumentsDirectory),
            ),
          ],
        ),
      ),
    );
  }
}
