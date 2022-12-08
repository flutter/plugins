// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface_legacy.dart';

import 'legacy/navigation_decision.dart';
import 'legacy/navigation_request.dart';
import 'legacy/web_view.dart';

void main() {
  runApp(const MaterialApp(home: _WebViewExample()));
}

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

const String kTransparentBackgroundPage = '''
<!DOCTYPE html>
<html>
<head>
  <title>Transparent background test</title>
</head>
<style type="text/css">
  body { background: transparent; margin: 0; padding: 0; }
  #container { position: relative; margin: 0; padding: 0; width: 100vw; height: 100vh; }
  #shape { background: #FF0000; width: 200px; height: 100%; margin: 0; padding: 0; position: absolute; top: 0; bottom: 0; left: calc(50% - 100px); }
  p { text-align: center; }
</style>
<body>
  <div id="container">
    <p>Transparent background test</p>
    <div id="shape"></div>
  </div>
</body>
</html>
''';

const String kLocalFileExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
  This is an example page used to demonstrate how to load a local file or HTML
  string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
  webview</a> plugin.
</p>

</body>
</html>
''';

class _WebViewExample extends StatefulWidget {
  const _WebViewExample({Key? key}) : super(key: key);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<_WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          _NavigationControls(_controller.future),
          _SampleMenu(_controller.future),
        ],
      ),
      body: WebView(
        initialUrl: 'https://flutter.dev/',
        onWebViewCreated: (WebViewController controller) {
          _controller.complete(controller);
        },
        javascriptChannels: _createJavascriptChannels(context),
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            print('blocking navigation to $request}');
            return NavigationDecision.prevent;
          }
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        },
        backgroundColor: const Color(0x80000000),
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
                final String url = (await controller.data!.currentUrl())!;
                ScaffoldMessenger.of(context).showSnackBar(
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

Set<JavascriptChannel> _createJavascriptChannels(BuildContext context) {
  return <JavascriptChannel>{
    JavascriptChannel(
        name: 'Snackbar',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message.message)));
        }),
  };
}

enum _MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
  doPostRequest,
  setCookie,
  transparentBackground,
}

class _SampleMenu extends StatelessWidget {
  const _SampleMenu(this.controller);

  final Future<WebViewController> controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<_MenuOptions>(
          key: const ValueKey<String>('ShowPopupMenu'),
          onSelected: (_MenuOptions value) {
            switch (value) {
              case _MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data!, context);
                break;
              case _MenuOptions.listCookies:
                _onListCookies(controller.data!, context);
                break;
              case _MenuOptions.clearCookies:
                _onClearCookies(controller.data!, context);
                break;
              case _MenuOptions.addToCache:
                _onAddToCache(controller.data!, context);
                break;
              case _MenuOptions.listCache:
                _onListCache(controller.data!, context);
                break;
              case _MenuOptions.clearCache:
                _onClearCache(controller.data!, context);
                break;
              case _MenuOptions.navigationDelegate:
                _onNavigationDelegateExample(controller.data!, context);
                break;
              case _MenuOptions.loadFlutterAsset:
                _onLoadFlutterAssetExample(controller.data!, context);
                break;
              case _MenuOptions.loadLocalFile:
                _onLoadLocalFileExample(controller.data!, context);
                break;
              case _MenuOptions.loadHtmlString:
                _onLoadHtmlStringExample(controller.data!, context);
                break;
              case _MenuOptions.doPostRequest:
                _onDoPostRequest(controller.data!, context);
                break;
              case _MenuOptions.setCookie:
                _onSetCookie(controller.data!, context);
                break;
              case _MenuOptions.transparentBackground:
                _onTransparentBackground(controller.data!, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<_MenuOptions>>[
            PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.showUserAgent,
              enabled: controller.hasData,
              child: const Text('Show user agent'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadFlutterAsset,
              child: Text('Load Flutter Asset'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadHtmlString,
              child: Text('Load HTML string'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.loadLocalFile,
              child: Text('Load local file'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.doPostRequest,
              child: Text('Post Request'),
            ),
            const PopupMenuItem<_MenuOptions>(
              value: _MenuOptions.setCookie,
              child: Text('Set Cookie'),
            ),
            const PopupMenuItem<_MenuOptions>(
              key: ValueKey<String>('ShowTransparentBackgroundExample'),
              value: _MenuOptions.transparentBackground,
              child: Text('Transparent background example'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Snackbar JavaScript channel we registered
    // with the WebView.
    await controller.runJavascript(
        'Snackbar.postMessage("User Agent: " + navigator.userAgent);');
  }

  Future<void> _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
        await controller.runJavascriptReturningResult('document.cookie');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  Future<void> _onAddToCache(
      WebViewController controller, BuildContext context) async {
    await controller.runJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  Future<void> _onListCache(
      WebViewController controller, BuildContext context) async {
    await controller.runJavascript('caches.keys()'
        // ignore: missing_whitespace_between_adjacent_strings
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Snackbar.postMessage(caches))');
  }

  Future<void> _onClearCache(
      WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cache cleared.'),
    ));
  }

  Future<void> _onClearCookies(
      WebViewController controller, BuildContext context) async {
    final bool hadCookies = await WebView.platform.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
        base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  Future<void> _onLoadFlutterAssetExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  Future<void> _onLoadLocalFileExample(
      WebViewController controller, BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();

    await controller.loadFile(pathToIndex);
  }

  Future<void> _onLoadHtmlStringExample(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kLocalFileExamplePage);
  }

  Future<void> _onDoPostRequest(
      WebViewController controller, BuildContext context) async {
    final WebViewRequest request = WebViewRequest(
      uri: Uri.parse('https://httpbin.org/post'),
      method: WebViewRequestMethod.post,
      headers: <String, String>{'foo': 'bar', 'Content-Type': 'text/plain'},
      body: Uint8List.fromList('Test Body'.codeUnits),
    );
    await controller.loadRequest(request);
  }

  Future<void> _onSetCookie(
      WebViewController controller, BuildContext context) async {
    await WebViewCookieManager.instance.setCookie(
      const WebViewCookie(
          name: 'foo', value: 'bar', domain: 'httpbin.org', path: '/anything'),
    );
    await controller.loadUrl('https://httpbin.org/anything');
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

  Future<void> _onTransparentBackground(
      WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kTransparentBackgroundPage);
  }

  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File('$tmpDir/www/index.html');

    await Directory('$tmpDir/www').create(recursive: true);
    await indexFile.writeAsString(kLocalFileExamplePage);

    return indexFile.path;
  }
}

class _NavigationControls extends StatelessWidget {
  const _NavigationControls(this._webViewControllerFuture)
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
        final WebViewController? controller = snapshot.data;

        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoBack()) {
                        await controller.goBack();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No back history item')),
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
                      if (await controller!.canGoForward()) {
                        await controller.goForward();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No forward history item')),
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
                      controller!.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}

/// Callback type for handling messages sent from JavaScript running in a web view.
typedef JavascriptMessageHandler = void Function(JavascriptMessage message);

// // Copyright 2013 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
//
// // ignore_for_file: public_member_api_docs
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
//
// void main() {
//   runApp(const MaterialApp(home: WebViewExample()));
// }
//
// const String kNavigationExamplePage = '''
// <!DOCTYPE html><html>
// <head><title>Navigation Delegate Example</title></head>
// <body>
// <p>
// The navigation delegate is set to block navigation to the youtube website.
// </p>
// <ul>
// <ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
// <ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
// </ul>
// </body>
// </html>
// ''';
//
// const String kLocalExamplePage = '''
// <!DOCTYPE html>
// <html lang="en">
// <head>
// <title>Load file or HTML string example</title>
// </head>
// <body>
//
// <h1>Local demo page</h1>
// <p>
//   This is an example page used to demonstrate how to load a local file or HTML
//   string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
//   webview</a> plugin.
// </p>
//
// </body>
// </html>
// ''';
//
// const String kTransparentBackgroundPage = '''
//   <!DOCTYPE html>
//   <html>
//   <head>
//     <title>Transparent background test</title>
//   </head>
//   <style type="text/css">
//     body { background: transparent; margin: 0; padding: 0; }
//     #container { position: relative; margin: 0; padding: 0; width: 100vw; height: 100vh; }
//     #shape { background: red; width: 200px; height: 200px; margin: 0; padding: 0; position: absolute; top: calc(50% - 100px); left: calc(50% - 100px); }
//     p { text-align: center; }
//   </style>
//   <body>
//     <div id="container">
//       <p>Transparent background test</p>
//       <div id="shape"></div>
//     </div>
//   </body>
//   </html>
// ''';
//
// class WebViewExample extends StatefulWidget {
//   const WebViewExample({Key? key, this.cookieManager}) : super(key: key);
//
//   final PlatformWebViewCookieManager? cookieManager;
//
//   @override
//   State<WebViewExample> createState() => _WebViewExampleState();
// }
//
// class _WebViewExampleState extends State<WebViewExample> {
//   late final PlatformWebViewController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = PlatformWebViewController(
//       WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true),
//     )
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x80000000))
//       ..setPlatformNavigationDelegate(
//         PlatformNavigationDelegate(
//           const PlatformNavigationDelegateCreationParams(),
//         )
//           ..setOnProgress((int progress) {
//             print('WebView is loading (progress : $progress%)');
//           })
//           ..setOnPageStarted((String url) {
//             print('Page started loading: $url');
//           })
//           ..setOnPageFinished((String url) {
//             print('Page finished loading: $url');
//           })
//           ..setOnWebResourceError((WebResourceError error) {
//             print('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   isForMainFrame: ${error.isForMainFrame}
//           ''');
//           })
//           ..setOnNavigationRequest((NavigationRequest request) {
//             if (request.url.startsWith('https://www.youtube.com/')) {
//               print('blocking navigation to ${request.url}');
//               return NavigationDecision.prevent;
//             }
//             print('allowing navigation to ${request.url}');
//             return NavigationDecision.navigate;
//           }),
//       )
//       ..addJavaScriptChannel(JavaScriptChannelParams(
//         name: 'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         },
//       ))
//       ..loadRequest(LoadRequestParams(
//         uri: Uri.parse('https://flutter.dev'),
//       ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green,
//       appBar: AppBar(
//         title: const Text('Flutter WebView example'),
//         // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
//         actions: <Widget>[
//           NavigationControls(webViewController: _controller),
//           SampleMenu(
//             webViewController: _controller,
//             cookieManager: widget.cookieManager,
//           ),
//         ],
//       ),
//       body: PlatformWebViewWidget(
//         PlatformWebViewWidgetCreationParams(controller: _controller),
//       ).build(context),
//       floatingActionButton: favoriteButton(),
//     );
//   }
//
//   Widget favoriteButton() {
//     return FloatingActionButton(
//       onPressed: () async {
//         final String? url = await _controller.currentUrl();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Favorited $url')),
//         );
//       },
//       child: const Icon(Icons.favorite),
//     );
//   }
// }
//
// enum MenuOptions {
//   showUserAgent,
//   listCookies,
//   clearCookies,
//   addToCache,
//   listCache,
//   clearCache,
//   navigationDelegate,
//   doPostRequest,
//   loadLocalFile,
//   loadFlutterAsset,
//   loadHtmlString,
//   transparentBackground,
//   setCookie,
// }
//
// class SampleMenu extends StatelessWidget {
//   SampleMenu({
//     Key? key,
//     required this.webViewController,
//     PlatformWebViewCookieManager? cookieManager,
//   })  : cookieManager = cookieManager ??
//             PlatformWebViewCookieManager(
//               const PlatformWebViewCookieManagerCreationParams(),
//             ),
//         super(key: key);
//
//   final PlatformWebViewController webViewController;
//   late final PlatformWebViewCookieManager cookieManager;
//
//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<MenuOptions>(
//       key: const ValueKey<String>('ShowPopupMenu'),
//       onSelected: (MenuOptions value) {
//         switch (value) {
//           case MenuOptions.showUserAgent:
//             _onShowUserAgent();
//             break;
//           case MenuOptions.listCookies:
//             _onListCookies(context);
//             break;
//           case MenuOptions.clearCookies:
//             _onClearCookies(context);
//             break;
//           case MenuOptions.addToCache:
//             _onAddToCache(context);
//             break;
//           case MenuOptions.listCache:
//             _onListCache();
//             break;
//           case MenuOptions.clearCache:
//             _onClearCache(context);
//             break;
//           case MenuOptions.navigationDelegate:
//             _onNavigationDelegateExample();
//             break;
//           case MenuOptions.doPostRequest:
//             _onDoPostRequest();
//             break;
//           case MenuOptions.loadLocalFile:
//             _onLoadLocalFileExample();
//             break;
//           case MenuOptions.loadFlutterAsset:
//             _onLoadFlutterAssetExample();
//             break;
//           case MenuOptions.loadHtmlString:
//             _onLoadHtmlStringExample();
//             break;
//           case MenuOptions.transparentBackground:
//             _onTransparentBackground();
//             break;
//           case MenuOptions.setCookie:
//             _onSetCookie();
//             break;
//         }
//       },
//       itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.showUserAgent,
//           child: Text('Show user agent'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.listCookies,
//           child: Text('List cookies'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.clearCookies,
//           child: Text('Clear cookies'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.addToCache,
//           child: Text('Add to cache'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.listCache,
//           child: Text('List cache'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.clearCache,
//           child: Text('Clear cache'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.navigationDelegate,
//           child: Text('Navigation Delegate example'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.doPostRequest,
//           child: Text('Post Request'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.loadHtmlString,
//           child: Text('Load HTML string'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.loadLocalFile,
//           child: Text('Load local file'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.loadFlutterAsset,
//           child: Text('Load Flutter Asset'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           key: ValueKey<String>('ShowTransparentBackgroundExample'),
//           value: MenuOptions.transparentBackground,
//           child: Text('Transparent background example'),
//         ),
//         const PopupMenuItem<MenuOptions>(
//           value: MenuOptions.setCookie,
//           child: Text('Set cookie'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _onShowUserAgent() {
//     // Send a message with the user agent string to the Toaster JavaScript channel we registered
//     // with the WebView.
//     return webViewController.runJavaScript(
//       'Toaster.postMessage("User Agent: " + navigator.userAgent);',
//     );
//   }
//
//   Future<void> _onListCookies(BuildContext context) async {
//     final String cookies = await webViewController
//         .runJavaScriptReturningResult('document.cookie') as String;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           const Text('Cookies:'),
//           _getCookieList(cookies),
//         ],
//       ),
//     ));
//   }
//
//   Future<void> _onAddToCache(BuildContext context) async {
//     await webViewController.runJavaScript(
//       'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";',
//     );
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       content: Text('Added a test entry to cache.'),
//     ));
//   }
//
//   Future<void> _onListCache() {
//     return webViewController.runJavaScript('caches.keys()'
//         // ignore: missing_whitespace_between_adjacent_strings
//         '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
//         '.then((caches) => Toaster.postMessage(caches))');
//   }
//
//   Future<void> _onClearCache(BuildContext context) async {
//     await webViewController.clearCache();
//     await webViewController.clearLocalStorage();
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       content: Text('Cache cleared.'),
//     ));
//   }
//
//   Future<void> _onClearCookies(BuildContext context) async {
//     final bool hadCookies = await cookieManager.clearCookies();
//     String message = 'There were cookies. Now, they are gone!';
//     if (!hadCookies) {
//       message = 'There are no cookies.';
//     }
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//     ));
//   }
//
//   Future<void> _onNavigationDelegateExample() {
//     final String contentBase64 = base64Encode(
//       const Utf8Encoder().convert(kNavigationExamplePage),
//     );
//     return webViewController.loadRequest(
//       LoadRequestParams(
//         uri: Uri.parse('data:text/html;base64,$contentBase64'),
//       ),
//     );
//   }
//
//   Future<void> _onSetCookie() async {
//     await cookieManager.setCookie(
//       const WebViewCookie(
//         name: 'foo',
//         value: 'bar',
//         domain: 'httpbin.org',
//         path: '/anything',
//       ),
//     );
//     await webViewController.loadRequest(LoadRequestParams(
//       uri: Uri.parse('https://httpbin.org/anything'),
//     ));
//   }
//
//   Future<void> _onDoPostRequest() {
//     return webViewController.loadRequest(LoadRequestParams(
//       uri: Uri.parse('https://httpbin.org/post'),
//       method: LoadRequestMethod.post,
//       headers: const <String, String>{
//         'foo': 'bar',
//         'Content-Type': 'text/plain',
//       },
//       body: Uint8List.fromList('Test Body'.codeUnits),
//     ));
//   }
//
//   Future<void> _onLoadLocalFileExample() async {
//     final String pathToIndex = await _prepareLocalFile();
//     await webViewController.loadFile(pathToIndex);
//   }
//
//   Future<void> _onLoadFlutterAssetExample() {
//     return webViewController.loadFlutterAsset('assets/www/index.html');
//   }
//
//   Future<void> _onLoadHtmlStringExample() {
//     return webViewController.loadHtmlString(kLocalExamplePage);
//   }
//
//   Future<void> _onTransparentBackground() {
//     return webViewController.loadHtmlString(kTransparentBackgroundPage);
//   }
//
//   Widget _getCookieList(String cookies) {
//     if (cookies == null || cookies == '""') {
//       return Container();
//     }
//     final List<String> cookieList = cookies.split(';');
//     final Iterable<Text> cookieWidgets =
//         cookieList.map((String cookie) => Text(cookie));
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       mainAxisSize: MainAxisSize.min,
//       children: cookieWidgets.toList(),
//     );
//   }
//
//   static Future<String> _prepareLocalFile() async {
//     final String tmpDir = (await getTemporaryDirectory()).path;
//     final File indexFile = File(
//         <String>{tmpDir, 'www', 'index.html'}.join(Platform.pathSeparator));
//
//     await indexFile.create(recursive: true);
//     await indexFile.writeAsString(kLocalExamplePage);
//
//     return indexFile.path;
//   }
// }
//
// class NavigationControls extends StatelessWidget {
//   const NavigationControls({Key? key, required this.webViewController})
//       : super(key: key);
//
//   final PlatformWebViewController webViewController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () async {
//             if (await webViewController.canGoBack()) {
//               await webViewController.goBack();
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('No back history item')),
//               );
//               return;
//             }
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.arrow_forward_ios),
//           onPressed: () async {
//             if (await webViewController.canGoForward()) {
//               await webViewController.goForward();
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('No forward history item')),
//               );
//               return;
//             }
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.replay),
//           onPressed: () => webViewController.reload(),
//         ),
//       ],
//     );
//   }
// }
