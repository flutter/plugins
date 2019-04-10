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

  group('error handling', () {
    test('invalid host', () async {
      final Completer<WebViewError> errorCompleter = Completer<WebViewError>();
      await pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'https://example.invalid/',
            onWebViewCreated: (WebViewController controller) {},
            onReceivedError: (WebViewError error) {
              errorCompleter.complete(error);
            },
            onPageFinished: (String url) {
              // fail if page finished without error.
              errorCompleter.complete(null);
            },
          ),
        ),
      );
      final WebViewError error = await errorCompleter.future;
      expect(error, isNotNull);
      expect(error.isConnectError, true);
      expect(error.connectErrorType, WebViewConnectErrorType.connect);
    });
    test('internal server error', () async {
      final Completer<WebViewError> errorCompleter = Completer<WebViewError>();
      await pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WebView(
            key: GlobalKey(),
            initialUrl: 'https://httpstat.us/500',
            onWebViewCreated: (WebViewController controller) {},
            onReceivedError: (WebViewError error) {
              errorCompleter.complete(error);
            },
            onPageFinished: (String url) {
              // fail if page finished without error.
              errorCompleter.complete(null);
            },
          ),
        ),
      );
      final WebViewError error = await errorCompleter.future;
      expect(error, isNotNull);
      expect(error.isConnectError, false);
      expect(error.statusCode, 500);
    });
  });
}

Future<void> pumpWidget(Widget widget) {
  runApp(widget);
  return WidgetsBinding.instance.endOfFrame;
}
