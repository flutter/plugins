// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

class WebViewExample extends StatelessWidget {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
          const SampleMenu(),
        ],
      ),
      body: WebView(
        initialUrl: 'https://flutter.io',
        javaScriptMode: JavaScriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
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
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        FutureBuilder<WebViewController>(
          builder: (BuildContext context,
                  AsyncSnapshot<WebViewController> snapshot) =>
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () async {
                    final WebViewController controller = snapshot.data;
                    final bool canGoBack = await controller.canGoBack();
                    if (canGoBack) {
                      controller.goBack();
                    } else {
                      Scaffold.of(context).showSnackBar(const SnackBar(
                          content: Text("No back history item")));
                    }
                  }),
          future: _webViewControllerFuture,
        ),
        FutureBuilder<WebViewController>(
          builder: (BuildContext context,
                  AsyncSnapshot<WebViewController> snapshot) =>
              IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () async {
                    final WebViewController controller = snapshot.data;
                    final bool canGoForward = await controller.canGoForward();
                    if (canGoForward) {
                      controller.goForward();
                    } else {
                      Scaffold.of(context).showSnackBar(const SnackBar(
                          content: Text("No forward history item")));
                    }
                  }),
          future: _webViewControllerFuture,
        ),
      ],
    );
  }
}
