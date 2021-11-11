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
import 'package:webview_flutter_android/webview_widget.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_webview.pigeon.dart';
import 'webview_widget_test.mocks.dart';

@GenerateMocks([
  android_webview.WebSettings,
  android_webview.WebView,
  WebViewAndroidDownloadListener,
  WebViewAndroidJavaScriptChannel,
  WebViewAndroidWebChromeClient,
  WebViewAndroidWebViewClient,
  JavascriptChannelRegistry,
  WebViewPlatformCallbacksHandler,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$AndroidWebViewWidget', () {
    // late MockTestWebViewHostApi mockWebViewHostApi;
    // late MockTestWebSettingsHostApi mockWebSettingsHostApi;
    // late MockTestWebViewClientHostApi mockWebViewClientHostApi;
    // late MockTestWebChromeClientHostApi mockWebChromeClientHostApi;
    // late MockTestJavaScriptChannelHostApi mockJavaScriptChannelHostApi;
    // late MockTestDownloadListenerHostApi mockDownloadListenerHostApi;
    //

    late MockWebView mockWebView;
    late MockWebSettings mockWebSettings;

    late MockWebViewPlatformCallbacksHandler mockCallbacksHandler;
    late WebViewAndroidWebViewClient webViewClient;
    late WebViewAndroidDownloadListener downloadListener;
    late WebViewAndroidWebChromeClient webChromeClient;

    //late WebViewAndroidJavaScriptChannel javaScriptChannel;
    late MockJavascriptChannelRegistry mockJavascriptChannelRegistry;
    //
    setUp(() {
      //   mockWebViewHostApi = MockTestWebViewHostApi();
      //   mockWebSettingsHostApi = MockTestWebSettingsHostApi();
      //   mockWebViewClientHostApi = MockTestWebViewClientHostApi();
      //   mockWebChromeClientHostApi = MockTestWebChromeClientHostApi();
      //   mockJavaScriptChannelHostApi = MockTestJavaScriptChannelHostApi();
      //   mockDownloadListenerHostApi = MockTestDownloadListenerHostApi();
      //
      //   TestWebViewHostApi.setup(mockWebViewHostApi);
      //   TestWebSettingsHostApi.setup(mockWebSettingsHostApi);
      //   TestWebViewClientHostApi.setup(mockWebViewClientHostApi);
      //   TestWebChromeClientHostApi.setup(mockWebChromeClientHostApi);
      //   TestJavaScriptChannelHostApi.setup(mockJavaScriptChannelHostApi);
      //   TestDownloadListenerHostApi.setup(mockDownloadListenerHostApi);
      //

      mockWebView = MockWebView();
      mockWebSettings = MockWebSettings();
      when(mockWebView.settings).thenReturn(mockWebSettings);

      mockCallbacksHandler = MockWebViewPlatformCallbacksHandler();

      mockJavascriptChannelRegistry = MockJavascriptChannelRegistry();

      //
      //   final InstanceManager instanceManager = InstanceManager();
      //   android_webview.WebView.api = WebViewHostApiImpl(
      //     instanceManager: instanceManager,
      //   );
      //   android_webview.WebSettings.api = WebSettingsHostApiImpl(
      //     instanceManager: instanceManager,
      //   );
      //   android_webview.JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
      //     instanceManager: instanceManager,
      //   );
      //   android_webview.WebViewClient.api = WebViewClientHostApiImpl(
      //     instanceManager: instanceManager,
      //   );
      //   android_webview.DownloadListener.api = DownloadListenerHostApiImpl(
      //     instanceManager: instanceManager,
      //   );
      //   android_webview.WebChromeClient.api = WebChromeClientHostApiImpl(
      //     instanceManager: instanceManager,
      //   );
    });

    // Builds a AndroidWebViewWidget with default parameters.
    Future<WebViewAndroidPlatformController> buildWidget(
      WidgetTester tester, {
      CreationParams? creationParams,
    }) async {
      webViewClient = WebViewAndroidWebViewClient(
        callbacksHandler: mockCallbacksHandler,
        loadUrl: mockWebView.loadUrl,
      );
      downloadListener = WebViewAndroidDownloadListener(
        callbacksHandler: mockCallbacksHandler,
        loadUrl: mockWebView.loadUrl,
      );
      webChromeClient = WebViewAndroidWebChromeClient(
        callbacksHandler: mockCallbacksHandler,
      );

      final WebViewAndroidPlatformController controller =
          WebViewAndroidPlatformController(
        webView: mockWebView,
        webViewClient: webViewClient,
        downloadListener: downloadListener,
        webChromeClient: webChromeClient,
        creationParams: creationParams ?? CreationParams(),
        callbacksHandler: mockCallbacksHandler,
        javascriptChannelRegistry: mockJavascriptChannelRegistry,
      );

      await tester.pumpWidget(AndroidWebViewWidget(
        controller: controller,
        onBuildWidget: () => Container(),
      ));

      // await tester.pumpWidget(
      //   AndroidWebViewWidget(
      //     onBuildWidget: onBuildWidget ??
      //         (WebViewAndroidPlatformController controller) {
      //           controllerCompleter.complete(controller);
      //           return Container();
      //         },
      //     creationParams: creationParams ?? CreationParams(),
      //     webViewPlatformCallbacksHandler:
      //         callbacksHandler ?? mockCallbacksHandler,
      //     javascriptChannelRegistry:
      //         javascriptChannelRegistry ?? mockJavascriptChannelRegistry,
      //     useHybridComposition: useHybridComposition ?? false,
      //   ),
      // );

      return controller;
    }

    testWidgets('Create Widget', (WidgetTester tester) async {
      await buildWidget(tester);

      verify(mockWebSettings.setDomStorageEnabled(true));
      verify(mockWebSettings.setJavaScriptCanOpenWindowsAutomatically(true));
      verify(mockWebSettings.setSupportMultipleWindows(true));
      verify(mockWebSettings.setLoadWithOverviewMode(true));
      verify(mockWebSettings.setUseWideViewPort(true));
      verify(mockWebSettings.setDisplayZoomControls(false));
      verify(mockWebSettings.setBuiltInZoomControls(true));

      verifyInOrder([
        mockWebView.setWebViewClient(webViewClient),
        mockWebView.setDownloadListener(downloadListener),
        mockWebView.setWebChromeClient(webChromeClient),
      ]);
    });

    // testWidgets(
    //   'Create Widget with Hybrid Composition',
    //   (WidgetTester tester) async {
    //     await buildWidget(tester, useHybridComposition: true);
    //     verify(mockWebViewHostApi.create(0, true));
    //   },
    // );
    //
    group('CreationParams', () {
      testWidgets('initialUrl', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(initialUrl: 'https://www.google.com'),
        );
        verify(mockWebView.loadUrl(
          'https://www.google.com',
          <String, String>{},
        ));
      });

      testWidgets('userAgent', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(userAgent: 'MyUserAgent'),
        );

        verify(mockWebSettings.setUserAgentString('MyUserAgent'));
      });

      testWidgets('autoMediaPlaybackPolicy true', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          ),
        );

        verify(mockWebSettings.setMediaPlaybackRequiresUserGesture(any));
      });

      testWidgets('autoMediaPlaybackPolicy false', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          ),
        );

        verify(mockWebSettings.setMediaPlaybackRequiresUserGesture(false));
      });

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            javascriptChannelNames: <String>{'a', 'b'},
          ),
        );

        final List<dynamic> javaScriptChannels =
            verify(mockWebView.addJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'a');
        expect(javaScriptChannels[1].channelName, 'b');
      });

      group('WebSettings', () {
        testWidgets('javascriptMode', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: WebSetting<String?>.absent(),
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
          );

          verify(mockWebSettings.setJavaScriptEnabled(true));
        });

        // testWidgets('hasNavigationDelegate', (WidgetTester tester) async {
        //   await buildWidget(
        //     tester,
        //     creationParams: CreationParams(
        //       webSettings: WebSettings(
        //         userAgent: WebSetting<String?>.absent(),
        //         hasNavigationDelegate: true,
        //       ),
        //     ),
        //   );
        //
        //   verify(mockWebViewClientHostApi.create(any, true));
        // });

        // testWidgets('debuggingEnabled', (WidgetTester tester) async {
        //   await buildWidget(
        //     tester,
        //     creationParams: CreationParams(
        //       webSettings: WebSettings(
        //         userAgent: WebSetting<String?>.absent(),
        //         debuggingEnabled: true,
        //       ),
        //     ),
        //   );
        //
        //   verify(mockWebSettings.setWebContentsDebuggingEnabled(true));
        // });

        testWidgets('userAgent', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: WebSetting<String?>.of('myUserAgent'),
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
                userAgent: WebSetting<String?>.absent(),
                zoomEnabled: false,
              ),
            ),
          );

          verify(mockWebSettings.setSupportZoom(false));
        });
      });
    });

    group('$WebViewAndroidPlatformController', () {
      testWidgets('loadUrl', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        verify(mockWebView.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        ));
      });

      testWidgets('currentUrl', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.getUrl())
            .thenAnswer((_) => Future<String>.value('https://www.google.com'));
        expect(controller.currentUrl(), completion('https://www.google.com'));
      });

      testWidgets('canGoBack', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.canGoBack()).thenAnswer(
          (_) => Future<bool>.value(false),
        );
        expect(controller.canGoBack(), completion(false));
      });

      testWidgets('canGoForward', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.canGoForward()).thenAnswer(
          (_) => Future<bool>.value(true),
        );
        expect(controller.canGoForward(), completion(true));
      });

      testWidgets('goBack', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.goBack();
        verify(mockWebView.goBack());
      });

      testWidgets('goForward', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.goForward();
        verify(mockWebView.goForward());
      });

      testWidgets('reload', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.reload();
        verify(mockWebView.reload());
      });

      testWidgets('clearCache', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.clearCache();
        verify(mockWebView.clearCache(true));
      });

      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          controller.evaluateJavascript('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascriptReturningResult', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          controller.runJavascriptReturningResult('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('runJavascript', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.evaluateJavascript('runJavaScript')).thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          controller.runJavascript('runJavaScript'),
          completes,
        );
      });

      testWidgets('addJavascriptChannels', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.addJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels =
            verify(mockWebView.addJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'c');
        expect(javaScriptChannels[1].channelName, 'd');
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.addJavascriptChannels(<String>{'c', 'd'});
        await controller.removeJavascriptChannels(<String>{'c', 'd'});
        final List<dynamic> javaScriptChannels =
            verify(mockWebView.removeJavaScriptChannel(captureAny)).captured;
        expect(javaScriptChannels[0].channelName, 'c');
        expect(javaScriptChannels[1].channelName, 'd');
      });

      testWidgets('getTitle', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.getTitle())
            .thenAnswer((_) => Future<String>.value('Web Title'));
        expect(controller.getTitle(), completion('Web Title'));
      });

      testWidgets('scrollTo', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.scrollTo(1, 2);
        verify(mockWebView.scrollTo(1, 2));
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        await controller.scrollBy(3, 4);
        verify(mockWebView.scrollBy(3, 4));
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.getScrollX()).thenAnswer((_) => Future<int>.value(23));
        expect(controller.getScrollX(), completion(23));
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        final WebViewAndroidPlatformController controller =
            await buildWidget(tester);

        when(mockWebView.getScrollY()).thenAnswer((_) => Future<int>.value(25));
        expect(controller.getScrollY(), completion(25));
      });
    });
  });
}
