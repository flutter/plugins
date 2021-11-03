// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'web_view.dart';

void main() {
  runApp(MaterialApp(home: _WebViewExample()));
}

class _WebViewExample extends StatefulWidget {
  const _WebViewExample({Key? key}) : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<_WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
      ),
      body: WebView(
        initialUrl: 'https://flutter.dev',
        onWebViewCreated: (WebViewController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
