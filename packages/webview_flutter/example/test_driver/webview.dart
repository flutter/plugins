// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);
  tearDownAll(() => allTestsCompleter.complete(null));

  test('initalUrl', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    final String currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter.dev/');
  });

  test('loadUrl', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await controller.loadUrl('https://www.google.com/');
    final String currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://www.google.com/');
  });

  // enable this once https://github.com/flutter/flutter/issues/31510
  // is resolved.
  test('loadUrl with headers', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final StreamController<String> pageLoads = StreamController<String>();
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: 'https://flutter.dev/',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String url) {
            pageLoads.add(url);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    final Map<String, String> headers = <String, String>{
      'test_header': 'flutter_test_header'
    };
    await controller.loadUrl('https://flutter-header-echo.herokuapp.com/',
        headers: headers);
    final String currentUrl = await controller.currentUrl();
    expect(currentUrl, 'https://flutter-header-echo.herokuapp.com/');

    await pageLoads.stream.firstWhere((String url) => url == currentUrl);
    final String content = await controller
        .evaluateJavascript('document.documentElement.innerText');
    expect(content.contains('flutter_test_header'), isTrue);
  });

  test('JavaScriptChannel', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final List<String> messagesReceived = <String>[];
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          // This is the data URL for: '<!DOCTYPE html>'
          initialUrl:
              'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
          javascriptMode: JavascriptMode.unrestricted,
          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
          // ignore: prefer_collection_literals
          javascriptChannels: <JavascriptChannel>[
            JavascriptChannel(
              name: 'Echo',
              onMessageReceived: (JavascriptMessage message) {
                messagesReceived.add(message.message);
              },
            ),
          ].toSet(),
          onPageFinished: (String url) {
            pageLoaded.complete(null);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    expect(messagesReceived, isEmpty);
    await controller.evaluateJavascript('Echo.postMessage("hello");');
    expect(messagesReceived, equals(<String>['hello']));
  });

  test('set custom userAgent', () async {
    final Completer<WebViewController> controllerCompleter1 =
        Completer<WebViewController>();
    final GlobalKey _globalKey = GlobalKey();
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'https://flutter.dev/',
          javascriptMode: JavascriptMode.unrestricted,
          userAgent: 'Custom_User_Agent1',
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter1.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller1 = await controllerCompleter1.future;
    final String customUserAgent1 = await controller1.getUserAgent();
    expect(customUserAgent1, 'Custom_User_Agent1');
    // rebuild the WebView with a different user agent.
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'https://flutter.dev/',
          javascriptMode: JavascriptMode.unrestricted,
          userAgent: 'Custom_User_Agent2',
        ),
      ),
    );

    final String customUserAgent2 = await controller1.getUserAgent();
    expect(customUserAgent2, 'Custom_User_Agent2');
  });

  test('use default platform userAgent after webView is rebuilt', () async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    final GlobalKey _globalKey = GlobalKey();
    // Build the webView with no user agent to get the default platform user agent.
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'https://flutter.dev/',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    final String defaultPlatformUserAgent = await controller.getUserAgent();
    // rebuild the WebView with a custom user agent.
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'https://flutter.dev/',
          javascriptMode: JavascriptMode.unrestricted,
          userAgent: 'Custom_User_Agent',
        ),
      ),
    );
    final String customUserAgent = await controller.getUserAgent();
    expect(customUserAgent, 'Custom_User_Agent');
    // rebuilds the WebView with no user agent.
    await pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: _globalKey,
          initialUrl: 'https://flutter.dev/',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );

    final String customUserAgent2 = await controller.getUserAgent();
    expect(customUserAgent2, defaultPlatformUserAgent);
  });
}

Future<void> pumpWidget(Widget widget) {
  runApp(widget);
  return WidgetsBinding.instance.endOfFrame;
}
