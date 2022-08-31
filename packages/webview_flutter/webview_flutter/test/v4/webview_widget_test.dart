// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter/src/v4/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';

import 'webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[PlatformWebViewWidget])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebViewWidget', () {
    testWidgets('build', (WidgetTester tester) async {
      final MockPlatformWebViewWidget mockPlatformWebViewWidget =
          MockPlatformWebViewWidget();
      when(mockPlatformWebViewWidget.build(any)).thenReturn(
        const Text('WebView'),
      );

      final WebViewWidget webViewWidget = WebViewWidget.fromPlatform(
        platform: mockPlatformWebViewWidget,
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));
    });
  });
}
