// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _linkMessage;
  bool _isCreatingLink = false;

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = new DynamicLinkParameters(
      domain: 'cx4k7.app.goo.gl',
      link: Uri.parse('https://google.com'),
      androidParameters: new AndroidParameters(
        packageName: 'io.flutter.plugins.firebasedynamiclinksexample',
      ),
      dynamicLinkParametersOptions: new DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: new IosParameters(
        bundleId: 'io.flutter.plugins.firebaseDynamicLinksExample',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Dynamic Links Example'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  new RaisedButton(
                    onPressed: !_isCreatingLink
                        ? () => _createDynamicLink(false)
                        : null,
                    child: const Text('Get Long Link'),
                  ),
                  new RaisedButton(
                    onPressed: !_isCreatingLink
                        ? () => _createDynamicLink(true)
                        : null,
                    child: const Text('Get Short Link'),
                  ),
                ],
              ),
              new Text(
                _linkMessage ?? '',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
