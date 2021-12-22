// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart' as web_kit;
import 'package:webview_flutter_wkwebview/src/webview_cupertino_widget.dart';

import 'webview_cupertino_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  web_kit.WebView,
  web_kit.WebViewConfiguration,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewProxy,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$WebViewCupertinoWidget', () {
    late MockWebView mockWebView;
    late MockWebViewProxy mockWebViewProxy;
    late MockWebViewConfiguration mockWebViewConfiguration;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    setUp(() {
      mockWebView = MockWebView();
      mockWebViewConfiguration = MockWebViewConfiguration();
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
      String systemVersion = '14.0',
    }) async {
      await tester.pumpWidget(WebViewCupertinoWidget(
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
        systemVersion: systemVersion,
        onBuildWidget: (WebViewCupertinoPlatformController controller) {
          return Container();
        },
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('build $WebViewCupertinoWidget', (WidgetTester tester) async {
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

        mockitoVerifySetterWorkaround(
          mockWebViewConfiguration,
          #mediaTypesRequiringUserActionForPlayback,
          <web_kit.AudiovisualMediaType>{web_kit.AudiovisualMediaType.all},
        );
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

        mockitoVerifySetterWorkaround(
          mockWebViewConfiguration,
          #mediaTypesRequiringUserActionForPlayback,
          <web_kit.AudiovisualMediaType>{web_kit.AudiovisualMediaType.none},
        );
      });

      testWidgets(
        'autoMediaPlaybackPolicy true with systemVersion < 10.0',
        (WidgetTester tester) async {
          await buildWidget(
            tester,
            systemVersion: '9.5',
            creationParams: CreationParams(
              autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy
                  .require_user_action_for_all_media_types,
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                hasNavigationDelegate: false,
              ),
            ),
          );

          mockitoVerifySetterWorkaround(
            mockWebViewConfiguration,
            #requiresUserActionForMediaPlayback,
            true,
          );
        },
      );

      testWidgets(
        'autoMediaPlaybackPolicy true with systemVersion < 9.0',
        (WidgetTester tester) async {
          await buildWidget(
            tester,
            systemVersion: '8.5',
            creationParams: CreationParams(
              autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy
                  .require_user_action_for_all_media_types,
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                hasNavigationDelegate: false,
              ),
            ),
          );

          mockitoVerifySetterWorkaround(
            mockWebViewConfiguration,
            #mediaPlaybackRequiresUserAction,
            true,
          );
        },
      );

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

          mockitoVerifySetterWorkaround(
            mockWebViewConfiguration,
            #allowsInlineMediaPlayback,
            true,
          );
        });
      });
    });
  });
}

// Workaround to test setters with mockito. This code is generated with
// the mock, but there is no way to access it. See
// https://github.com/dart-lang/mockito/issues/498
void mockitoVerifySetterWorkaround(
  Mock mock,
  Symbol memberName,
  Object? argument,
) {
  verify<dynamic>(mock.noSuchMethod(
    Invocation.setter(memberName, argument),
    returnValueForMissingStub: null,
  ));
}
