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
  WKScriptMessageHandler,
  WKWebView,
  WKWebViewConfiguration,
  WKUserContentController,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewWidgetProxy,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$WebKitWebViewWidget', () {
    late MockWKWebView mockWebView;
    late MockWebViewWidgetProxy mockWebViewWidgetProxy;
    late MockWKUserContentController mockUserContentController;
    late MockWKWebViewConfiguration mockWebViewConfiguration;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    late WebKitWebViewPlatformController testController;

    setUp(() {
      mockWebView = MockWKWebView();
      mockWebViewConfiguration = MockWKWebViewConfiguration();
      mockUserContentController = MockWKUserContentController();
      mockWebViewWidgetProxy = MockWebViewWidgetProxy();

      when(mockWebViewWidgetProxy.createWebView(any)).thenReturn(mockWebView);
      when(mockWebView.configuration).thenReturn(mockWebViewConfiguration);
      when(mockWebViewConfiguration.userContentController).thenReturn(
        mockUserContentController,
      );

      mockCallbacksHandler = MockWebViewPlatformCallbacksHandler();
      mockJavascriptChannelRegistry = MockJavascriptChannelRegistry();
    });

    // Builds a WebViewCupertinoWidget with default parameters.
    Future<void> buildWidget(
      WidgetTester tester, {
      CreationParams? creationParams,
      bool hasNavigationDelegate = false,
      bool hasProgressTracking = false,
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
        webViewProxy: mockWebViewWidgetProxy,
        configuration: mockWebViewConfiguration,
        onBuildWidget: (WebKitWebViewPlatformController controller) {
          testController = controller;
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

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(
          tester,
          creationParams: CreationParams(
            javascriptChannelNames: <String>{'a', 'b'},
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        final List<dynamic> javaScriptChannels = verify(
          mockUserContentController.addScriptMessageHandler(
            captureAny,
            captureAny,
          ),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'a');
        expect(
          javaScriptChannels[2],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'b');
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

    group('$WebKitWebViewPlatformController', () {
      testWidgets('addJavascriptChannels', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels = verify(
          mockUserContentController.addScriptMessageHandler(
              captureAny, captureAny),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'c');
        expect(
          javaScriptChannels[2],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'd');

        final List<WKUserScript> userScripts =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .cast<WKUserScript>();
        expect(userScripts[0].source, 'window.c = webkit.messageHandlers.c;');
        expect(
          userScripts[0].injectionTime,
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
        expect(userScripts[1].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[1].injectionTime,
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        reset(mockUserContentController);

        await testController.removeJavascriptChannels(<String>{'c'});

        verify(mockUserContentController.removeAllScriptMessageHandlers());
        verify(mockUserContentController.removeAllUserScripts());

        final List<dynamic> javaScriptChannels = verify(
          mockUserContentController.addScriptMessageHandler(
              captureAny, captureAny),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WKScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'd');

        final List<WKUserScript> userScripts =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .cast<WKUserScript>();
        expect(userScripts[0].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[0].injectionTime,
          WKUserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
      });
    });

    group('$JavascriptChannelRegistry', () {
      testWidgets('onJavascriptChannelMessage', (WidgetTester tester) async {
        when(mockWebViewWidgetProxy.createScriptMessageHandler()).thenReturn(
          MockWKScriptMessageHandler(),
        );

        await buildWidget(tester);
        await testController.addJavascriptChannels(<String>{'hello'});

        final MockWKScriptMessageHandler messageHandler = verify(
                mockUserContentController.addScriptMessageHandler(
                    captureAny, 'hello'))
            .captured
            .single as MockWKScriptMessageHandler;

        final dynamic didReceiveScriptMessage =
            verify(messageHandler.setDidReceiveScriptMessage(captureAny))
                .captured
                .single as void Function(
          WKUserContentController userContentController,
          WKScriptMessage message,
        );

        didReceiveScriptMessage(
          mockUserContentController,
          WKScriptMessage(name: 'hello', body: 'A message.'),
        );
        verify(mockJavascriptChannelRegistry.onJavascriptChannelMessage(
          'hello',
          'A message.',
        ));
      });
    });
  });
}
