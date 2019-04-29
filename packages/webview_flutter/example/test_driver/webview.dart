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
}

Future<void> pumpWidget(Widget widget) {
  runApp(widget);
  return WidgetsBinding.instance.endOfFrame;
}
