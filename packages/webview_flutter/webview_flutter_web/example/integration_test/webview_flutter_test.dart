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

  testWidgets('loadHtmlString', (WidgetTester tester) async {
    final WebWebViewController controller =
        WebWebViewController(const PlatformWebViewControllerCreationParams())
          ..loadHtmlString(
            'data:text/html;charset=utf-8,${Uri.encodeFull('test html')}',
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
    expect(
      element!.src,
      'data:text/html;charset=utf-8,data:text/html;charset=utf-8,test%2520html',
    );
  });
}
