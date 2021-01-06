// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:share/share.dart';

void main() {
  runApp(new DemoApp());
}

class DemoApp extends StatefulWidget {
  @override
  DemoAppState createState() => new DemoAppState();
}

class DemoAppState extends State<DemoApp> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Share Plugin Demo',
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Share Plugin Demo'),
          ),
          body: new Padding(
            padding: const EdgeInsets.all(24.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new TextField(
                  decoration: const InputDecoration(
                    labelText: 'Share:',
                    hintText: 'Enter some text and/or link to share',
                  ),
                  maxLines: 4,
                  onChanged: (String value) => setState(() {
                        text = value;
                      }),
                ),
                new ElevatedButton(
                  child: const Text('Share'),
                  onPressed: text.isNotEmpty
                      ? () {
                          share(text);
                        }
                      : null,
                ),
              ],
            ),
          )),
    );
  }
}
