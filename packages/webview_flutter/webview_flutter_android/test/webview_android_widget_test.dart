// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webview.dart'
    as android_webview;
import 'package:webview_flutter_android/webview_android_widget.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'webview_android_widget_test.mocks.dart';

@GenerateMocks(<Type>[
  android_webview.WebSettings,
  android_webview.WebView,
  WebViewAndroidDownloadListener,
  WebViewAndroidJavaScriptChannel,
  WebViewAndroidWebChromeClient,
  WebViewAndroidWebViewClient,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
  WebViewProxy,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$WebViewAndroidWidget', () {
    late MockWebView mockWebView;
    late MockWebSettings mockWebSettings;
    late MockWebViewProxy mockWebViewProxy;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late WebViewAndroidWebViewClient webViewClient;
    late WebViewAndroidDownloadListener downloadListener;
    late WebViewAndroidWebChromeClient webChromeClient;

    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;

    late WebViewAndroidPlatformController testController;

    setUp(() {
      mockWebView = MockWebView();
      mockWebSettings = MockWebSettings();
      when(mockWebView.settings).thenReturn(mockWebSettings);

      mockWebViewProxy = MockWebViewProxy();
      when(mockWebViewProxy.createWebView(
        useHybridComposition: anyNamed('useHybridComposition'),
      )).thenReturn(mockWebView);

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
      await tester.pumpWidget(WebViewAndroidWidget(
        useHybridComposition: useHybridComposition,
        creationParams: creationParams ??
            CreationParams(
                webSettings: WebSettings(
              // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
              // ignore: prefer_const_constructors
              userAgent: WebSetting<String?>.absent(),
              hasNavigationDelegate: hasNavigationDelegate,
              hasProgressTracking: hasProgressTracking,
            )),
        callbacksHandler: mockCallbacksHandler,
        javascriptChannelRegistry: mockJavascriptChannelRegistry,
        webViewProxy: mockWebViewProxy,
        onBuildWidget: (WebViewAndroidPlatformController controller) {
          testController = controller;
          return Container();
        },
      ));

      webViewClient = testController.webViewClient;
      downloadListener = testController.downloadListener;
      webChromeClient = testController.webChromeClient;
    }

    testWidgets('$WebViewAndroidWidget', (WidgetTester tester) async {
      await buildWidget(tester);

      verify(mockWebSettings.setDomStorageEnabled(true));
      verify(mockWebSettings.setJavaScriptCanOpenWindowsAutomatically(true));
      verify(mockWebSettings.setSupportMultipleWindows(true));
      verify(mockWebSettings.setLoadWithOverviewMode(true));
      verify(mockWebSettings.setUseWideViewPort(true));
      verify(mockWebSettings.setDisplayZoomControls(false));
      verify(mockWebSettings.setBuiltInZoomControls(true));

      verifyInOrder(<Future<void>>[
        mockWebView.setWebViewClient(webViewClient),
        mockWebView.setDownloadListener(downloadListener),
        mockWebView.setWebChromeClient(webChromeClient),
      ]);
    });

    testWidgets(
      'Create Widget with Hybrid Composition',
      (WidgetTester tester) async {
        await buildWidget(tester, useHybridComposition: true);
        verify(mockWebViewProxy.createWebView(useHybridComposition: true));
      },
    );

    group('$CreationParams', () {
      testWidgets('initialUrl', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            initialUrl: 'https://www.google.com',
            webSettings: WebSettings(
              // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
              // ignore: prefer_const_constructors
              userAgent: WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );
        verify(mockWebView.loadUrl(
          'https://www.google.com',
          <String, String>{},
        ));
      });

      testWidgets('userAgent', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            userAgent: 'MyUserAgent',
            webSettings: WebSettings(
              // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
              // ignore: prefer_const_constructors
              userAgent: WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mockWebSettings.setUserAgentString('MyUserAgent'));
      });

      testWidgets('autoMediaPlaybackPolicy true', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
            webSettings: WebSettings(
              // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
              // ignore: prefer_const_constructors
              userAgent: WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mockWebSettings.setMediaPlaybackRequiresUserGesture(any));
      });

      testWidgets('autoMediaPlaybackPolicy false', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            webSettings: WebSettings(
              // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
              // ignore: prefer_const_constructors
              userAgent: WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        verify(mockWebSettings.setMediaPlaybackRequiresUserGesture(false));
      });

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            javascriptChannelNames: <String>{'a', 'b'},
            webSettings: WebSettings(
              // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
              // ignore: prefer_const_constructors
              userAgent: WebSetting<String?>.absent(),
              hasNavigationDelegate: false,
            ),
          ),
        );

        final List<dynamic> javaScriptChannels =
            verify(mockWebView.addJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'a');
        expect(javaScriptChannels[1].channelName, 'b');
      });

      group('$WebSettings', () {
        testWidgets('javascriptMode', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
                // ignore: prefer_const_constructors
                userAgent: WebSetting<String?>.absent(),
                javascriptMode: JavascriptMode.unrestricted,
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebSettings.setJavaScriptEnabled(true));
        });

        testWidgets('hasNavigationDelegate', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
                // ignore: prefer_const_constructors
                userAgent: WebSetting<String?>.absent(),
                hasNavigationDelegate: true,
              ),
            ),
          );

          expect(testController.webViewClient.handlesNavigation, isTrue);
          expect(testController.webViewClient.shouldOverrideUrlLoading, isTrue);
        });

        testWidgets('debuggingEnabled', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
                // ignore: prefer_const_constructors
                userAgent: WebSetting<String?>.absent(),
                debuggingEnabled: true,
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebViewProxy.setWebContentsDebuggingEnabled(true));
        });

        testWidgets('userAgent', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
                // ignore: prefer_const_constructors
                userAgent: WebSetting<String?>.of('myUserAgent'),
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebSettings.setUserAgentString('myUserAgent'));
        });

        testWidgets('zoomEnabled', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                // TODO(mvanbeusekom): Cleanup and convert to const constructor when platform_interface is fixed (see https://github.com/flutter/flutter/issues/94311)
                // ignore: prefer_const_constructors
                userAgent: WebSetting<String?>.absent(),
                zoomEnabled: false,
                hasNavigationDelegate: false,
              ),
            ),
          );

          verify(mockWebSettings.setSupportZoom(false));
        });
      });
    });

    group('$WebViewPlatformController', () {
      testWidgets('loadUrl', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        verify(mockWebView.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        ));
      });

      testWidgets('currentUrl', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getUrl())
            .thenAnswer((_) => Future<String>.value('https://www.google.com'));
        expect(
            testController.currentUrl(), completion('https://www.google.com'));
      });

      testWidgets('canGoBack', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.canGoBack()).thenAnswer(
          (_) => Future<bool>.value(false),
        );
        expect(testController.canGoBack(), completion(false));
      });

      testWidgets('canGoForward', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.canGoForward()).thenAnswer(
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
        verify(mockWebView.clearCache(true));
      });

      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.evaluateJavascript('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascriptReturningResult', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          testController.runJavascriptReturningResult('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascript', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
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
        final List<dynamic> javaScriptChannels =
            verify(mockWebView.addJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'c');
        expect(javaScriptChannels[1].channelName, 'd');
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.addJavascriptChannels(<String>{'c', 'd'});
        await testController.removeJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels =
            verify(mockWebView.removeJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'c');
        expect(javaScriptChannels[1].channelName, 'd');
      });

      testWidgets('getTitle', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getTitle())
            .thenAnswer((_) => Future<String>.value('Web Title'));
        expect(testController.getTitle(), completion('Web Title'));
      });

      testWidgets('scrollTo', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.scrollTo(1, 2);
        verify(mockWebView.scrollTo(1, 2));
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        await buildWidget(tester);

        await testController.scrollBy(3, 4);
        verify(mockWebView.scrollBy(3, 4));
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getScrollX()).thenAnswer((_) => Future<int>.value(23));
        expect(testController.getScrollX(), completion(23));
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        await buildWidget(tester);

        when(mockWebView.getScrollY()).thenAnswer((_) => Future<int>.value(25));
        expect(testController.getScrollY(), completion(25));
      });
    });

    group('$WebViewPlatformCallbacksHandler', () {
      testWidgets('onPageStarted', (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onPageStarted(mockWebView, 'https://google.com');
        verify(mockCallbacksHandler.onPageStarted('https://google.com'));
      });

      testWidgets('onPageFinished', (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onPageFinished(mockWebView, 'https://google.com');
        verify(mockCallbacksHandler.onPageFinished('https://google.com'));
      });

      testWidgets('onWebResourceError from onReceivedError',
          (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onReceivedError(
          mockWebView,
          android_webview.WebViewClient.errorAuthentication,
          'description',
          'https://google.com',
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'description');
        expect(error.errorCode, -4);
        expect(error.failingUrl, 'https://google.com');
        expect(error.domain, isNull);
        expect(error.errorType, WebResourceErrorType.authentication);
      });

      testWidgets('onWebResourceError from onReceivedRequestError',
          (WidgetTester tester) async {
        await buildWidget(tester);
        webViewClient.onReceivedRequestError(
          mockWebView,
          android_webview.WebResourceRequest(
            url: 'https://google.com',
            isForMainFrame: true,
            isRedirect: false,
            hasGesture: false,
            method: 'POST',
            requestHeaders: <String, String>{},
          ),
          android_webview.WebResourceError(
            errorCode: android_webview.WebViewClient.errorUnsafeResource,
            description: 'description',
          ),
        );

        final WebResourceError error =
            verify(mockCallbacksHandler.onWebResourceError(captureAny))
                .captured
                .single as WebResourceError;
        expect(error.description, 'description');
        expect(error.errorCode, -16);
        expect(error.failingUrl, 'https://google.com');
        expect(error.domain, isNull);
        expect(error.errorType, WebResourceErrorType.unsafeResource);
      });

      testWidgets('onNavigationRequest from urlLoading',
          (WidgetTester tester) async {
        await buildWidget(tester, hasNavigationDelegate: true);
        when(mockCallbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isTrue, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        webViewClient.urlLoading(mockWebView, 'https://google.com');
        verify(mockCallbacksHandler.onNavigationRequest(
          url: 'https://google.com',
          isForMainFrame: true,
        ));
        verify(mockWebView.loadUrl('https://google.com', <String, String>{}));
      });

      testWidgets('onNavigationRequest from requestLoading',
          (WidgetTester tester) async {
        await buildWidget(tester, hasNavigationDelegate: true);
        when(mockCallbacksHandler.onNavigationRequest(
          isForMainFrame: argThat(isTrue, named: 'isForMainFrame'),
          url: 'https://google.com',
        )).thenReturn(true);

        webViewClient.requestLoading(
          mockWebView,
          android_webview.WebResourceRequest(
            url: 'https://google.com',
            isForMainFrame: true,
            isRedirect: false,
            hasGesture: false,
            method: 'POST',
            requestHeaders: <String, String>{},
          ),
        );
        verify(mockCallbacksHandler.onNavigationRequest(
          url: 'https://google.com',
          isForMainFrame: true,
        ));
        verify(mockWebView.loadUrl('https://google.com', <String, String>{}));
      });

      group('$JavascriptChannelRegistry', () {
        testWidgets('onJavascriptChannelMessage', (WidgetTester tester) async {
          await buildWidget(tester);

          await testController.addJavascriptChannels(<String>{'hello'});

          final WebViewAndroidJavaScriptChannel javaScriptChannel =
              verify(mockWebView.addJavaScriptChannel(captureAny))
                  .captured
                  .single as WebViewAndroidJavaScriptChannel;
          javaScriptChannel.postMessage('goodbye');
          verify(mockJavascriptChannelRegistry.onJavascriptChannelMessage(
            'hello',
            'goodbye',
          ));
        });
      });
    });
  });
}
