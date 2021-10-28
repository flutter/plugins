// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/webview_widget.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_webview.pigeon.dart';
import 'webview_widget_test.mocks.dart';

@GenerateMocks([
  TestWebViewHostApi,
  TestWebSettingsHostApi,
  TestWebViewClientHostApi,
  TestWebChromeClientHostApi,
  TestJavaScriptChannelHostApi,
  TestDownloadListenerHostApi,
  WebViewPlatformCallbacksHandler,
  JavascriptChannelRegistry,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$AndroidWebViewWidget', () {
    late TestWebViewHostApi mockWebViewHostApi;
    late TestWebSettingsHostApi mockWebSettingsHostApi;
    late TestWebViewClientHostApi mockWebViewClientHostApi;
    late TestWebChromeClientHostApi mockWebChromeClientHostApi;
    late TestJavaScriptChannelHostApi mockJavaScriptChannelHostApi;
    late TestDownloadListenerHostApi mockDownloadListenerHostApi;

    late WebViewPlatformCallbacksHandler mockCallbacksHandler;
    late JavascriptChannelRegistry mockJavascriptChannelRegistry;

    setUp(() {
      mockWebViewHostApi = MockTestWebViewHostApi();
      mockWebSettingsHostApi = MockTestWebSettingsHostApi();
      mockWebViewClientHostApi = MockTestWebViewClientHostApi();
      mockWebChromeClientHostApi = MockTestWebChromeClientHostApi();
      mockJavaScriptChannelHostApi = MockTestJavaScriptChannelHostApi();
      mockDownloadListenerHostApi = MockTestDownloadListenerHostApi();

      TestWebViewHostApi.setup(mockWebViewHostApi);
      TestWebSettingsHostApi.setup(mockWebSettingsHostApi);
      TestWebViewClientHostApi.setup(mockWebViewClientHostApi);
      TestWebChromeClientHostApi.setup(mockWebChromeClientHostApi);
      TestJavaScriptChannelHostApi.setup(mockJavaScriptChannelHostApi);
      TestDownloadListenerHostApi.setup(mockDownloadListenerHostApi);

      mockCallbacksHandler = MockWebViewPlatformCallbacksHandler();
      mockJavascriptChannelRegistry = MockJavascriptChannelRegistry();
    });

    testWidgets('Create Widget', (WidgetTester tester) async {
      late final AndroidWebViewPlatformController apple;
      await tester.pumpWidget(
        AndroidWebViewWidget(
          onBuildWidget: (AndroidWebViewPlatformController controller) {
            apple = controller;
            return Container();
          },
          creationParams: CreationParams(
            initialUrl: 'https://www.google.com',
          ),
          webViewPlatformCallbacksHandler: mockCallbacksHandler,
          javascriptChannelRegistry: mockJavascriptChannelRegistry,
          useHybridComposition: false,
        ),
      );

      verifyInOrder([
        mockWebViewHostApi.create(0, false),
        mockWebViewHostApi.loadUrl(
          0,
          'https://www.google.com',
          <String, String>{},
        ),
      ]);
    });
  });
}
