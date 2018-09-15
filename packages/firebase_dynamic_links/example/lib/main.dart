// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() {
  runApp(MaterialApp(
    title: 'Dynamic Links Example',
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => _MainScreen(),
      '/helloworld': (BuildContext context) => _DynamicLinkScreen(),
    },
  ));
}

class _MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  String _linkMessage;
  bool _isCreatingLink = false;
  @override
  BuildContext get context => super.context;

  @override
  void initState() {
    super.initState();
    _retrieveDynamicLink();
  }

  Future<void> _retrieveDynamicLink() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      domain: 'cx4k7.app.goo.gl',
      link: Uri.parse('https://dynamic.link.example/helloworld'),
      androidParameters: AndroidParameters(
        packageName: 'io.flutter.plugins.firebasedynamiclinksexample',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
        minimumVersion: '0',
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
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Links Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: !_isCreatingLink
                        ? () => _createDynamicLink(false)
                        : null,
                    child: const Text('Get Long Link'),
                  ),
                  RaisedButton(
                    onPressed: !_isCreatingLink
                        ? () => _createDynamicLink(true)
                        : null,
                    child: const Text('Get Short Link'),
                  ),
                ],
              ),
              Text(
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

class _DynamicLinkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World DeepLink'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
