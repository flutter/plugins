// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          (controller != null) ? NavigationControls(controller) : Container(),
          const SampleMenu(),
        ],
      ),
      body: WebView(
        initialUrl: 'https://flutter.io',
        javaScriptMode: JavaScriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          setState(() {
            controller = webViewController;
          });
        },
      ),
    );
  }
}

class SampleMenu extends StatelessWidget {
  const SampleMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('You selected: $value')));
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'Item 1',
              child: Text('Item 1'),
            ),
            const PopupMenuItem<String>(
              value: 'Item 2',
              child: Text('Item 2'),
            ),
          ],
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewController)
      : assert(_webViewController != null);

  final WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              final bool canGoBack = await _webViewController.canGoBack;
              if (canGoBack) {
                _webViewController.goBack();
              } else {
                Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("Can't go back")));
              }
            }),
        IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              final bool canGoForward = await _webViewController.canGoForward;
              if (canGoForward) {
                _webViewController.goForward();
              } else {
                Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("Can't go forward")));
              }
            }),
      ],
    );
  }
}
