// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

class WebViewExample extends StatelessWidget {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  final String _invalidUrlRegex = r'^(https).+(twitter.com)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
          SampleMenu(_controller.future),
        ],
      ),
      body: WebView(
        initialUrl: 'https://flutter.io',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
          _setupListeners(webViewController);
        },
        invalidUrlRegex: _invalidUrlRegex,
      ),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                final String url = await controller.data.currentUrl();
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("Favorited $url")),
                );
              },
              child: const Icon(Icons.favorite),
            );
          }
          return Container();
        });
  }

  void _setupListeners(WebViewController controller) {
    controller.onPageStarted.listen((String url) {
      print('onPageStarted: $url');
    });
    controller.onPageFinished.listen((String url) {
      print('onPageFinished: $url');
    });
    controller.onUrlShouldLoad.listen((String url) {
      print('onUrlShouldLoad: $url');
      final RegExp regex = RegExp(_invalidUrlRegex);
      if (regex.firstMatch(url) != null) {
        _key.currentState.showSnackBar(
          SnackBar(
              content: Text("Denied"
                  " $url")),
        );
      }
    });
  }
}

enum MenuOptions {
  evaluateJavascript,
  toast,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);
  final Future<WebViewController> controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.evaluateJavascript:
                _onEvaluateJavascript(controller.data, context);
                break;
              case MenuOptions.toast:
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You selected: $value'),
                  ),
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
                PopupMenuItem<MenuOptions>(
                  value: MenuOptions.evaluateJavascript,
                  child: const Text('Evaluate JavaScript'),
                  enabled: controller.hasData,
                ),
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.toast,
                  child: Text('Make a toast'),
                ),
              ],
        );
      },
    );
  }

  void _onEvaluateJavascript(
      WebViewController controller, BuildContext context) async {
    final String result = await controller
        .evaluateJavascript("document.body.style.backgroundColor = 'red'");
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('JavaScript evaluated, the result is: $result'),
      ),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        controller.goBack();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        controller.goForward();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No forward history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
