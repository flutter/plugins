// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';
import 'package:webview_flutter_wkwebview/src/web_kit_webview_widget.dart';

import 'web_kit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  WKWebView,
  WKWebViewConfiguration,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewProxy,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$WebKitWebViewWidget', () {
    late MockWKWebView mockWebView;
    late MockWebViewProxy mockWebViewProxy;
    late MockWKWebViewConfiguration mockWebViewConfiguration;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    setUp(() {
      mockWebView = MockWKWebView();
      mockWebViewConfiguration = MockWKWebViewConfiguration();
      mockWebViewProxy = MockWebViewProxy();

      when(mockWebViewProxy.createWebView(any)).thenReturn(mockWebView);

      mockCallbacksHandler = MockWebViewPlatformCallbacksHandler();
      mockJavascriptChannelRegistry = MockJavascriptChannelRegistry();
    });

    // Builds a WebViewCupertinoWidget with default parameters.
    Future<void> buildWidget(
      WidgetTester tester, {
      CreationParams? creationParams,
      bool hasNavigationDelegate = false,
      bool hasProgressTracking = false,
      bool useHybridComposition = false,
    }) async {
      await tester.pumpWidget(WebKitWebViewWidget(
        creationParams: creationParams ??
            CreationParams(
                webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: hasNavigationDelegate,
              hasProgressTracking: hasProgressTracking,
            )),
        callbacksHandler: mockCallbacksHandler,
        javascriptChannelRegistry: mockJavascriptChannelRegistry,
        webViewProxy: mockWebViewProxy,
        configuration: mockWebViewConfiguration,
        onBuildWidget: (WebKitWebViewPlatformController controller) {
          return Container();
        },
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('build $WebKitWebViewWidget', (WidgetTester tester) async {
      await buildWidget(tester);
    });

    group('$CreationParams', () {
      testWidgets('autoMediaPlaybackPolicy true', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(
            mockWebViewConfiguration.mediaTypesRequiringUserActionForPlayback =
                <WKAudiovisualMediaType>{
          WKAudiovisualMediaType.all,
        });
      });

      testWidgets('autoMediaPlaybackPolicy false', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(
            mockWebViewConfiguration.mediaTypesRequiringUserActionForPlayback =
                <WKAudiovisualMediaType>{
          WKAudiovisualMediaType.none,
        });
      });

      group('$WebSettings', () {
        testWidgets('allowsInlineMediaPlayback', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                allowsInlineMediaPlayback: true,
              ),
            ),
          );

          verify(mockWebViewConfiguration.allowsInlineMediaPlayback = true);
        });
      });
    });
  });
}
