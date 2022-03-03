// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';
import 'package:webview_flutter_wkwebview/src/web_kit_webview_widget.dart';

import 'web_kit_webview_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  UIScrollView,
  WKScriptMessageHandler,
  WKWebView,
  WKWebViewConfiguration,
  WKUIDelegate,
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
    late MockWKUIDelegate mockUIDelegate;
    late MockUIScrollView mockScrollView;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    late WebKitWebViewPlatformController testController;

    setUp(() {
      mockWebView = MockWKWebView();
      mockWebViewConfiguration = MockWKWebViewConfiguration();
      mockUserContentController = MockWKUserContentController();
      mockUIDelegate = MockWKUIDelegate();
      mockScrollView = MockUIScrollView();
      mockWebViewWidgetProxy = MockWebViewWidgetProxy();

      when(mockWebViewWidgetProxy.createWebView(any)).thenReturn(mockWebView);
      when(mockWebViewWidgetProxy.createUIDelgate()).thenReturn(mockUIDelegate);
      when(mockWebView.configuration).thenReturn(mockWebViewConfiguration);
      when(mockWebViewConfiguration.userContentController).thenReturn(
        mockUserContentController,
      );
      when(mockWebView.scrollView).thenReturn(mockScrollView);

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

    testWidgets('Requests to open a new window loads request in same window',
        (WidgetTester tester) async {
      await buildWidget(tester);

      final dynamic onCreateWebView =
          verify(mockUIDelegate.onCreateWebView = captureAny).captured.single
              as void Function(WKWebViewConfiguration, WKNavigationAction);

      const NSUrlRequest request = NSUrlRequest(url: 'https://google.com');
      onCreateWebView(
        mockWebViewConfiguration,
        const WKNavigationAction(
          request: request,
          targetFrame: WKFrameInfo(isMainFrame: false),
        ),
      );

      verify(mockWebView.loadRequest(request));
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
      testWidgets('loadFile', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadFile('/path/to/file.html');
        verify(mockWebView.loadFileUrl('/path/to/file.html', '/path/to'));
      });

      testWidgets('loadFlutterAsset', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadFlutterAsset('test_assets/index.html');
        verify(mockWebView.loadFlutterAsset('test_assets/index.html'));
      });

      testWidgets('loadHtmlString', (WidgetTester tester) async {
        await buildWidget(tester);

        const String htmlString = '<html><body>Test data.</body></html>';
        await testController.loadHtmlString(htmlString, baseUrl: 'baseUrl');

        verify(mockWebView.loadHtmlString(
          '<html><body>Test data.</body></html>',
          'baseUrl',
        ));
      });

      testWidgets('loadUrl', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        final NSUrlRequest request = verify(mockWebView.loadRequest(captureAny))
            .captured
            .single as NSUrlRequest;
        expect(request.url, 'https://www.google.com');
        expect(request.allHttpHeaderFields, <String, String>{'a': 'header'});
      });

      group('loadRequest', () {
        testWidgets('Throws ArgumentError for empty scheme',
            (WidgetTester tester) async {
          await buildWidget(tester);

          expect(
              () async => await testController.loadRequest(
                    WebViewRequest(
                      uri: Uri.parse('www.google.com'),
                      method: WebViewRequestMethod.get,
                    ),
                  ),
              throwsA(const TypeMatcher<ArgumentError>()));
        });

        testWidgets('GET without headers', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
          ));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.allHttpHeaderFields, <String, String>{});
          expect(request.httpMethod, 'get');
        });

        testWidgets('GET with headers', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.get,
            headers: <String, String>{'a': 'header'},
          ));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.allHttpHeaderFields, <String, String>{'a': 'header'});
          expect(request.httpMethod, 'get');
        });

        testWidgets('POST without body', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
            uri: Uri.parse('https://www.google.com'),
            method: WebViewRequestMethod.post,
          ));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
        });

        testWidgets('POST with body', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
              uri: Uri.parse('https://www.google.com'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('Test Body'.codeUnits)));

          final NSUrlRequest request =
              verify(mockWebView.loadRequest(captureAny)).captured.single
                  as NSUrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
          expect(
            request.httpBody,
            Uint8List.fromList('Test Body'.codeUnits),
          );
        });
      });

      testWidgets('canGoBack', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.canGoBack).thenAnswer(
          (_) => Future<bool>.value(false),
        );
        expect(testController.canGoBack(), completion(false));
      });

      testWidgets('canGoForward', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.canGoForward).thenAnswer(
          (_) => Future<bool>.value(true),
        );
        expect(testController.canGoForward(), completion(true));
      });

      testWidgets('goBack', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.goBack();
        verify(mockWebView.goBack());
      });

      testWidgets('goForward', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.goForward();
        verify(mockWebView.goForward());
      });

      testWidgets('reload', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.reload();
        verify(mockWebView.reload());
      });

      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascriptReturningResult', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascriptReturningResult('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavaScript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascript('runJavaScript'),
          completes,
        );
      });

      testWidgets('getTitle', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.title)
            .thenAnswer((_) => Future<String>.value('Web Title'));
        expect(testController.getTitle(), completion('Web Title'));
      });

      testWidgets('scrollTo', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.scrollTo(2, 4);
        await untilCalled<dynamic>(mockScrollView.noSuchMethod(
          Invocation.setter(#contentOffset, const Point<double>(2.0, 4.0)),
          returnValueForMissingStub: null,
        ));
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockScrollView.contentOffset).thenAnswer(
            (_) => Future<Point<double>>.value(const Point<double>(8.0, 16.0)));
        await testController.scrollBy(2, 4);
        await untilCalled<dynamic>(mockScrollView.noSuchMethod(
          Invocation.setter(#contentOffset, const Point<double>(10.0, 20.0)),
          returnValueForMissingStub: null,
        ));
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockScrollView.contentOffset).thenAnswer(
            (_) => Future<Point<double>>.value(const Point<double>(8.0, 16.0)));
        expect(testController.getScrollX(), completion(8.0));
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        await buildWidget(tester);

        await buildWidget(tester);

        when(mockScrollView.contentOffset).thenAnswer(
            (_) => Future<Point<double>>.value(const Point<double>(8.0, 16.0)));
        expect(testController.getScrollY(), completion(16.0));
      });

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
            verify(messageHandler.didReceiveScriptMessage = captureAny)
                .captured
                .single as void Function(
          WKUserContentController userContentController,
          WKScriptMessage message,
        );

        didReceiveScriptMessage(
          mockUserContentController,
          const WKScriptMessage(name: 'hello', body: 'A message.'),
        );
        verify(mockJavascriptChannelRegistry.onJavascriptChannelMessage(
          'hello',
          'A message.',
        ));
      });
    });
  });
}
