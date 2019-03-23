// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  WebViewController _controller;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller, _isLoading),
          SampleMenu(_controller),
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: 'https://flutter.dev',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            setState(() {
              _controller = webViewController;
            });
          },
          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
          // ignore: prefer_collection_literals
          javascriptChannels: <JavascriptChannel>[
            _toasterJavascriptChannel(context),
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onReceivedError: (WebViewError error) {
            if (error.isForMainFrame) {
              setState(() {
                _isLoading = false;
              });
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text('Error while loading web site.'),
                        content: Text(error.description),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text('Retry'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _controller.loadUrl(error.url);
                            },
                          ),
                          FlatButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                      ));
            }
          },
        );
      }),
      floatingActionButton: favoriteButton(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Widget favoriteButton() {
    return Builder(builder: (BuildContext context) {
      if (_controller != null) {
        return FloatingActionButton(
          onPressed: () async {
            final String url = await _controller.currentUrl();
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Favorited $url')),
            );
          },
          child: const Icon(Icons.favorite),
        );
      }
      return Container();
    });
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
  error404,
  error500,
  errorUnknownHost,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final WebViewController controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuOptions>(
      onSelected: (MenuOptions value) {
        switch (value) {
          case MenuOptions.showUserAgent:
            _onShowUserAgent(controller, context);
            break;
          case MenuOptions.listCookies:
            _onListCookies(controller, context);
            break;
          case MenuOptions.clearCookies:
            _onClearCookies(context);
            break;
          case MenuOptions.addToCache:
            _onAddToCache(controller, context);
            break;
          case MenuOptions.listCache:
            _onListCache(controller, context);
            break;
          case MenuOptions.clearCache:
            _onClearCache(controller, context);
            break;
          case MenuOptions.navigationDelegate:
            _onNavigationDelegateExample(controller, context);
            break;
          case MenuOptions.error404:
            controller.loadUrl('https://httpstat.us/404');
            break;
          case MenuOptions.error500:
            controller.loadUrl('https://httpstat.us/500');
            break;
          case MenuOptions.errorUnknownHost:
            controller.loadUrl('https://unknown.invalid/');
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text('Show user agent'),
              enabled: controller != null,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.error404,
              child: Text('Force Error: 404'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.error500,
              child: Text('Force Error: 500'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.errorUnknownHost,
              child: Text('Force Error: Unknown Host'),
            ),
          ],
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
        await controller.evaluateJavascript('document.cookie');
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
        cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewController, this._isLoading)
      : assert(_isLoading != null);

  final WebViewController _webViewController;

  final bool _isLoading;

  @override
  Widget build(BuildContext context) {
    final bool webViewReady = _webViewController != null;
    final WebViewController controller = _webViewController;
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
                      const SnackBar(content: Text("No forward history item")),
                    );
                    return;
                  }
                },
        ),
        webViewReady && _isLoading
            ? IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  controller.stopLoading();
                },
              )
            : IconButton(
                icon: const Icon(Icons.replay),
                onPressed: !webViewReady
                    ? null
                    : () {
                        controller.reload();
                      },
              ),
      ],
    );
  }
}
