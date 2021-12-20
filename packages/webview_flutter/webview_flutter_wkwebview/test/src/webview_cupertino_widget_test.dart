// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/ios_kit/ios_kit.dart' as ios_kit;
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart' as web_kit;
import 'package:webview_flutter_wkwebview/src/webview_cupertino_widget.dart';

import 'webview_cupertino_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  web_kit.WebView,
  ios_kit.ScrollView,
  web_kit.Preferences,
  web_kit.UserContentController,
  web_kit.WebViewConfiguration,
  web_kit.WebsiteDataStore,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewProxy,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$WebViewCupertinoWidget', () {
    late MockWebView mockWebView;
    late MockPreferences mockPreferences;
    late MockWebViewProxy mockWebViewProxy;
    late MockUserContentController mockUserContentController;
    late MockScrollView mockScrollView;
    late MockWebViewConfiguration mockWebViewConfiguration;
    late MockWebsiteDataStore mockWebsiteDataStore;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    late WebViewCupertinoPlatformController testController;

    setUp(() {
      mockWebView = MockWebView();
      mockPreferences = MockPreferences();
      mockScrollView = MockScrollView();
      mockUserContentController = MockUserContentController();
      mockWebViewConfiguration = MockWebViewConfiguration();
      mockWebViewProxy = MockWebViewProxy();
      mockWebsiteDataStore = MockWebsiteDataStore();

      when(mockWebViewProxy.createWebView(any)).thenReturn(mockWebView);
      when(mockWebView.scrollView).thenAnswer((_) {
        return Future<ios_kit.ScrollView>.value(mockScrollView);
      });

      mockCallbacksHandler = MockWebViewPlatformCallbacksHandler();
      mockJavascriptChannelRegistry = MockJavascriptChannelRegistry();
    });

    // Builds a AndroidWebViewWidget with default parameters.
    Future<void> buildWidget(
      WidgetTester tester, {
      CreationParams? creationParams,
      bool hasNavigationDelegate = false,
      bool hasProgressTracking = false,
      bool useHybridComposition = false,
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
        systemVersion: 14.0,
        applicationDocumentsDirectory: Directory('/'),
        preferences: mockPreferences,
        userContentController: mockUserContentController,
        dataStore: mockWebsiteDataStore,
        onBuildWidget: (WebViewCupertinoPlatformController controller) {
          testController = controller;
          return Container();
        },
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('build $WebViewCupertinoWidget', (WidgetTester tester) async {
      await buildWidget(tester);
    });

    testWidgets('loadRequest from onCreateWebView not main frame',
        (WidgetTester tester) async {
      await buildWidget(tester);

      final UrlRequest request = UrlRequest(url: 'https://google.com');
      testController.iosDelegate.onCreateWebView(
        mockWebViewConfiguration,
        web_kit.NavigationAction(
            request: request,
            targetFrame: web_kit.FrameInfo(isMainFrame: false)),
      );

      verify(mockWebView.loadRequest(request));
    });

    group('$CreationParams', () {
      testWidgets('initialUrl', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            initialUrl: 'https://www.google.com',
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );
        final UrlRequest request = verify(mockWebView.loadRequest(captureAny))
            .captured
            .single as UrlRequest;
        expect(request.url, 'https://www.google.com');
      });

      testWidgets('userAgent', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            userAgent: 'MyUserAgent',
            webSettings: WebSettings(
              userAgent: const WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        // Workaround to test setters with mockito. This code is generated with
        // the mock, but there is no way to access it.
        await untilCalled<dynamic>(mockWebView.noSuchMethod(
          Invocation.setter(#customUserAgent, 'MyUserAgent'),
          returnValueForMissingStub: null,
        ));
      });

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

        // Workaround to test setters with mockito. This code is generated with
        // the mock, but there is no way to access it.
        await untilCalled<dynamic>(mockWebViewConfiguration.noSuchMethod(
          Invocation.setter(#mediaTypesRequiringUserActionForPlayback,
              <web_kit.AudiovisualMediaType>{web_kit.AudiovisualMediaType.all}),
          returnValueForMissingStub: null,
        ));
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

        // Workaround to test setters with mockito. This code is generated with
        // the mock, but there is no way to access it.
        await untilCalled<dynamic>(mockWebViewConfiguration.noSuchMethod(
          Invocation.setter(
              #mediaTypesRequiringUserActionForPlayback,
              <web_kit.AudiovisualMediaType>{
                web_kit.AudiovisualMediaType.none
              }),
          returnValueForMissingStub: null,
        ));
      });

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
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
              captureAny, captureAny),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WebViewCupertinoScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'a');
        expect(
          javaScriptChannels[2],
          isA<WebViewCupertinoScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'b');
      });

      group('$WebSettings', () {
        testWidgets('javascriptMode', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                javascriptMode: JavascriptMode.unrestricted,
                hasNavigationDelegate: false,
              ),
            ),
          );

          // Workaround to test setters with mockito. This code is generated with
          // the mock, but there is no way to access it.
          await untilCalled<dynamic>(mockPreferences.noSuchMethod(
            Invocation.setter(#javaScriptEnabled, true),
            returnValueForMissingStub: null,
          ));
        });

        testWidgets('hasNavigationDelegate', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                hasNavigationDelegate: true,
              ),
            ),
          );

          expect(
            testController.navigationDelegate.onNavigationRequestCallback,
            isNotNull,
          );
          expect(
            testController.iosDelegate.onNavigationRequestCallback,
            isNotNull,
          );
        });

        testWidgets('userAgent', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.of('myUserAgent'),
                hasNavigationDelegate: false,
              ),
            ),
          );

          // Workaround to test setters with mockito. This code is generated with
          // the mock, but there is no way to access it.
          await untilCalled<dynamic>(mockWebView.noSuchMethod(
            Invocation.setter(#customUserAgent, 'myUserAgent'),
            returnValueForMissingStub: null,
          ));
        });

        testWidgets('zoomEnabled', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: const WebSetting<String?>.absent(),
                zoomEnabled: false,
                hasNavigationDelegate: false,
              ),
            ),
          );

          final web_kit.UserScript zoomScript =
              verify(mockUserContentController.addUserScript(captureAny))
                  .captured
                  .first as web_kit.UserScript;
          expect(zoomScript.isMainFrameOnly, isTrue);
          expect(zoomScript.injectionTime,
              web_kit.UserScriptInjectionTime.atDocumentEnd);
          expect(
            zoomScript.source,
            "var meta = document.createElement('meta');"
            "meta.name = 'viewport';"
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0,"
            "user-scalable=no';"
            "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
          );
        });
      });
    });

    group('$WebViewPlatformController', () {
      testWidgets('loadFile', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadFile('/path/to/file.html');
        verify(mockWebView.loadFileUrl('/path/to/file.html', '/path/to'));
      });

      testWidgets('loadFlutterAsset', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadFlutterAsset('test_assets/index.html');
        verify(mockWebView.loadFileUrl(
          '/test_assets/index.html',
          '/test_assets',
        ));
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

        final UrlRequest request = verify(mockWebView.loadRequest(captureAny))
            .captured
            .single as UrlRequest;
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

          final UrlRequest request = verify(mockWebView.loadRequest(captureAny))
              .captured
              .single as UrlRequest;
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

          final UrlRequest request = verify(mockWebView.loadRequest(captureAny))
              .captured
              .single as UrlRequest;
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

          final UrlRequest request = verify(mockWebView.loadRequest(captureAny))
              .captured
              .single as UrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
        });

        testWidgets('POST with body', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.loadRequest(WebViewRequest(
              uri: Uri.parse('https://www.google.com'),
              method: WebViewRequestMethod.post,
              body: Uint8List.fromList('Test Body'.codeUnits)));

          final UrlRequest request = verify(mockWebView.loadRequest(captureAny))
              .captured
              .single as UrlRequest;
          expect(request.url, 'https://www.google.com');
          expect(request.httpMethod, 'post');
          expect(
            request.httpBody,
            Uint8List.fromList('Test Body'.codeUnits),
          );
        });
      });

      testWidgets('currentUrl', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.url)
            .thenAnswer((_) => Future<String>.value('https://www.google.com'));
        expect(
            testController.currentUrl(), completion('https://www.google.com'));
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

      testWidgets('clearCache', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.clearCache();
        verify(mockWebsiteDataStore.removeDataOfTypes(
          <web_kit.WebsiteDataTypes>{
            web_kit.WebsiteDataTypes.memoryCache,
            web_kit.WebsiteDataTypes.diskCache,
            web_kit.WebsiteDataTypes.offlineWebApplicationCache,
          },
          DateTime.fromMillisecondsSinceEpoch(0),
        ));
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

      testWidgets('addJavascriptChannels', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels = verify(
          mockUserContentController.addScriptMessageHandler(
              captureAny, captureAny),
        ).captured;
        expect(
          javaScriptChannels[0],
          isA<WebViewCupertinoScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'c');
        expect(
          javaScriptChannels[2],
          isA<WebViewCupertinoScriptMessageHandler>(),
        );
        expect(javaScriptChannels[3], 'd');

        final List<web_kit.UserScript> userScripts =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .cast<web_kit.UserScript>();
        expect(userScripts[0].source, 'window.c = webkit.messageHandlers.c;');
        expect(
          userScripts[0].injectionTime,
          web_kit.UserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
        expect(userScripts[1].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[1].injectionTime,
          web_kit.UserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
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
          isA<WebViewCupertinoScriptMessageHandler>(),
        );
        expect(javaScriptChannels[1], 'd');

        final List<web_kit.UserScript> userScripts =
            verify(mockUserContentController.addUserScript(captureAny))
                .captured
                .cast<web_kit.UserScript>();
        expect(userScripts[0].source, 'window.d = webkit.messageHandlers.d;');
        expect(
          userScripts[0].injectionTime,
          web_kit.UserScriptInjectionTime.atDocumentStart,
        );
        expect(userScripts[0].isMainFrameOnly, false);
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

        // Workaround to test setters with mockito. This code is generated with
        // the mock, but there is no way to access it.
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

        // Workaround to test setters with mockito. This code is generated with
        // the mock, but there is no way to access it.
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
    });

    group('$WebViewPlatformCallbacksHandler', () {
      testWidgets('onPageStarted', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.url)
            .thenAnswer((_) => Future<String>.value('https://google.com'));
        testController.navigationDelegate
            .didStartProvisionalNavigation(mockWebView);

        await untilCalled(mockWebView.url);
        verify(mockCallbacksHandler.onPageStarted('https://google.com'));
      });

      testWidgets('onPageFinished', (WidgetTester tester) async {
        await buildWidget(tester);
        when(mockWebView.url)
            .thenAnswer((_) => Future<String>.value('https://google.com'));
        testController.navigationDelegate.didFinishNavigation(mockWebView);

        await untilCalled(mockWebView.url);
        verify(mockCallbacksHandler.onPageFinished('https://google.com'));
      });

      testWidgets('onWebResourceError from didFailNavigation',
          (WidgetTester tester) async {
        await buildWidget(tester);
        testController.navigationDelegate.didFailNavigation(
          mockWebView,
          FoundationError(
            code: web_kit.WebKitError.webViewInvalidated,
            domain: 'domain',
            localizedDescription: 'my desc',
          ),
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'my desc');
        expect(error.errorCode, web_kit.WebKitError.webViewInvalidated);
        expect(error.domain, 'domain');
        expect(error.errorType, WebResourceErrorType.webViewInvalidated);
      });

      testWidgets('onWebResourceError from didFailProvisionalNavigation',
          (WidgetTester tester) async {
        await buildWidget(tester);
        testController.navigationDelegate.didFailProvisionalNavigation(
          mockWebView,
          FoundationError(
            code: web_kit.WebKitError.webContentProcessTerminated,
            domain: 'domain',
            localizedDescription: 'my desc',
          ),
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'my desc');
        expect(
            error.errorCode, web_kit.WebKitError.webContentProcessTerminated);
        expect(error.domain, 'domain');
        expect(
          error.errorType,
          WebResourceErrorType.webContentProcessTerminated,
        );
      });

      testWidgets(
          'onWebResourceError from webViewWebContentProcessDidTerminate',
          (WidgetTester tester) async {
        await buildWidget(tester);
        testController.navigationDelegate.webViewWebContentProcessDidTerminate(
          mockWebView,
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, '');
        expect(
            error.errorCode, web_kit.WebKitError.webContentProcessTerminated);
        expect(error.domain, 'WKErrorDomain');
        expect(
          error.errorType,
          WebResourceErrorType.webContentProcessTerminated,
        );
      });

      testWidgets('onNavigationRequest from decidePolicyForNavigationAction',
          (WidgetTester tester) async {
        await buildWidget(tester, hasNavigationDelegate: true);
        when(mockCallbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isFalse, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        expect(
            testController.navigationDelegate.decidePolicyForNavigationAction(
              mockWebView,
              web_kit.NavigationAction(
                request: UrlRequest(url: 'https://google.com'),
                targetFrame: web_kit.FrameInfo(isMainFrame: false),
              ),
            ),
            completion(web_kit.NavigationActionPolicy.allow));
        verify(mockCallbacksHandler.onNavigationRequest(
          url: 'https://google.com',
          isForMainFrame: false,
        ));
      });

      testWidgets('onProgress', (WidgetTester tester) async {
        await buildWidget(tester, hasProgressTracking: true);
        verify(mockWebView.addObserver(
          testController.progressObserver,
          'estimatedProgress',
          <KeyValueObservingOptions>{
            KeyValueObservingOptions.new_,
          },
        ));

        testController.progressObserver.observeValue(
          'estimatedProgress',
          testController.progressObserver,
          <KeyValueChangeKey, Object?>{KeyValueChangeKey.new_: 0.32},
        );

        verify(mockCallbacksHandler.onProgress(32));
      });
    });

    group('$JavascriptChannelRegistry', () {
      testWidgets('onJavascriptChannelMessage', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'hello'});

        final WebViewCupertinoScriptMessageHandler messageHandler = verify(
                mockUserContentController.addScriptMessageHandler(
                    captureAny, 'hello'))
            .captured
            .single as WebViewCupertinoScriptMessageHandler;
        messageHandler.didReceiveScriptMessage(
            mockUserContentController,
            web_kit.ScriptMessage(
              name: 'hello',
              body: 'A message.',
            ));
        verify(mockJavascriptChannelRegistry.onJavascriptChannelMessage(
          'hello',
          'A message.',
        ));
      });
    });
  });
}
