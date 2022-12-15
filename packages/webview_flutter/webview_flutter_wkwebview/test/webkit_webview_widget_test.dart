// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';
import 'package:webview_flutter_wkwebview/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webkit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[WKWebViewConfiguration])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebKitWebViewWidget', () {
    testWidgets('build', (WidgetTester tester) async {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final WebKitWebViewController controller = WebKitWebViewController(
        WebKitWebViewControllerCreationParams(
          webKitProxy: WebKitProxy(
            createWebView: (
              WKWebViewConfiguration configuration, {
              void Function(
                String keyPath,
                NSObject object,
                Map<NSKeyValueChangeKey, Object?> change,
              )?
                  observeValue,
            }) {
              final WKWebView webView = WKWebView.detached(
                instanceManager: instanceManager,
              );
              instanceManager.addDartCreatedInstance(webView);
              return webView;
            },
            createWebViewConfiguration: () => MockWKWebViewConfiguration(),
          ),
        ),
      );

      final WebKitWebViewWidget widget = WebKitWebViewWidget(
        WebKitWebViewWidgetCreationParams(
          key: const Key('keyValue'),
          controller: controller,
          instanceManager: instanceManager,
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => widget.build(context)),
      );

      expect(find.byType(UiKitView), findsOneWidget);
      expect(find.byKey(const Key('keyValue')), findsOneWidget);
    });
  });
}
