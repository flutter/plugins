// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'URL Launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _launched;
  String _phone = '';

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchUniversalLinkIos(String url) async {
    if (await canLaunch('https://youtube.com')) {
      final bool nativeAppLaunchSucceeded = await launch(
        'https://youtube.com',
        forceSafariVC: false,
        universalLinksOnly: true,
      );
      if (!nativeAppLaunchSucceeded) {
        await launch(
          'https://youtube.com',
          forceSafariVC: true,
        );
      }
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    const String toLaunch = 'https://flutter.io';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  onChanged: (String text) => _phone = text,
                  decoration: const InputDecoration(
                      hintText: 'Input the phone number to launch')),
            ),
            RaisedButton(
              onPressed: () => setState(() {
                    _launched = _makePhoneCall('tel:$_phone');
                  }),
              child: const Text('Make phone call'),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(toLaunch),
            ),
            RaisedButton(
              onPressed: () => setState(() {
                    _launched = _launchInBrowser(toLaunch);
                  }),
              child: const Text('Launch in browser'),
            ),
            const Padding(padding: EdgeInsets.all(16.0)),
            RaisedButton(
              onPressed: () => setState(() {
                    _launched = _launchInWebViewOrVC(toLaunch);
                  }),
              child: const Text('Launch in app'),
            ),
            const Padding(padding: EdgeInsets.all(16.0)),
            RaisedButton(
              onPressed: () => setState(() {
                    _launched = _launchInWebViewWithJavaScript(toLaunch);
                  }),
              child: const Text('Launch in app(JavaScript ON)'),
            ),
            RaisedButton(
              onPressed: () => setState(() {
                    _launched = _launchUniversalLinkIos(toLaunch);
                  }),
              child: const Text(
                  'Launch a universal link in a native app, fallback to Safari.(Youtube)'),
            ),
            const Padding(padding: EdgeInsets.all(16.0)),
            RaisedButton(
              onPressed: () => setState(() {
                    _launched = _launchInWebViewOrVC(toLaunch);
                    Timer(const Duration(seconds: 5), () {
                      print('Closing WebView after 5 seconds...');
                      closeWebView();
                    });
                  }),
              child: const Text('Launch in app + close after 5 seconds'),
            ),
            const Padding(padding: EdgeInsets.all(16.0)),
            FutureBuilder<void>(future: _launched, builder: _launchStatus),
          ],
        ),
      ),
    );
  }
}
