// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter_web_example/web_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // URLs to navigate to in tests. These need to be URLs that we are confident will
  // always be accessible, and won't do redirection. (E.g., just
  // 'https://www.google.com/' will sometimes redirect traffic that looks
  // like it's coming from a bot, which is true of these tests).
  const String primaryUrl = 'https://flutter.dev/';
  const String secondaryUrl = 'https://www.google.com/robots.txt';

  testWidgets('initialUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: primaryUrl,
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    await controllerCompleter.future;
    // Since the URL can't be checked on web, there's no expectation. This is
    // just a sanity check that the call completes.
  });

  testWidgets('loadUrl', (WidgetTester tester) async {
    final Completer<WebViewController> controllerCompleter =
        Completer<WebViewController>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WebView(
          key: GlobalKey(),
          initialUrl: primaryUrl,
          onWebViewCreated: (WebViewController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final WebViewController controller = await controllerCompleter.future;
    await controller.loadUrl(secondaryUrl);
    // Since the URL can't be checked on web, there's no expectation. This is
    // just a sanity check that the call completes.
  });
}
