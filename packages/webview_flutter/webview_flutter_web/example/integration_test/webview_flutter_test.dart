// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // URLs to navigate to in tests. These need to be URLs that we are confident will
  // always be accessible, and won't do redirection. (E.g., just
  // 'https://www.google.com/' will sometimes redirect traffic that looks
  // like it's coming from a bot, which is true of these tests).
  const String primaryUrl = 'https://flutter.dev/';

  testWidgets('loadRequest', (WidgetTester tester) async {
    final WebWebViewController controller =
        WebWebViewController(const PlatformWebViewControllerCreationParams())
          ..loadRequest(
            LoadRequestParams(
              uri: Uri.parse(
                primaryUrl,
              ),
            ),
          );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(builder: (BuildContext context) {
          return WebWebViewWidget(
            PlatformWebViewWidgetCreationParams(controller: controller),
          ).build(context);
        }),
      ),
    );

    // Assert an iframe has been rendered to the DOM with the correct src attribute.
    final html.IFrameElement? element =
        html.document.querySelector('iframe') as html.IFrameElement?;
    expect(element, isNotNull);
    expect(element!.src, primaryUrl);
  });
}
