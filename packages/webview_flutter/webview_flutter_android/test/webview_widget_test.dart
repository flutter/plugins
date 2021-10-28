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
import 'package:webview_flutter_android/src/android_webview_api_impls.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';
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
    late MockTestWebViewHostApi mockWebViewHostApi;
    late MockTestWebSettingsHostApi mockWebSettingsHostApi;
    late MockTestWebViewClientHostApi mockWebViewClientHostApi;
    late MockTestWebChromeClientHostApi mockWebChromeClientHostApi;
    late MockTestJavaScriptChannelHostApi mockJavaScriptChannelHostApi;
    late MockTestDownloadListenerHostApi mockDownloadListenerHostApi;

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

      final InstanceManager instanceManager = InstanceManager();
      android_webview.WebView.api = WebViewHostApiImpl(
        instanceManager: instanceManager,
      );
      android_webview.WebSettings.api = WebSettingsHostApiImpl(
        instanceManager: instanceManager,
      );
      android_webview.JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
        instanceManager: instanceManager,
      );
      android_webview.WebViewClient.api = WebViewClientHostApiImpl(
        instanceManager: instanceManager,
      );
      android_webview.DownloadListener.api = DownloadListenerHostApiImpl(
        instanceManager: instanceManager,
      );
      android_webview.WebChromeClient.api = WebChromeClientHostApiImpl(
        instanceManager: instanceManager,
      );
    });

    // Builds a AndroidWebViewWidget with default parameters.
    Future<AndroidWebViewPlatformController> buildWidget(
      WidgetTester tester, {
      Widget Function(AndroidWebViewPlatformController platformController)?
          onBuildWidget,
      CreationParams? creationParams,
      WebViewPlatformCallbacksHandler? webViewPlatformCallbacksHandler,
      JavascriptChannelRegistry? javascriptChannelRegistry,
      bool? useHybridComposition,
    }) async {
      final Completer<AndroidWebViewPlatformController> controllerCompleter =
          Completer<AndroidWebViewPlatformController>();

      await tester.pumpWidget(
        AndroidWebViewWidget(
          onBuildWidget: onBuildWidget ??
              (AndroidWebViewPlatformController controller) {
                controllerCompleter.complete(controller);
                return Container();
              },
          creationParams: creationParams ?? CreationParams(),
          webViewPlatformCallbacksHandler:
              webViewPlatformCallbacksHandler ?? mockCallbacksHandler,
          javascriptChannelRegistry:
              javascriptChannelRegistry ?? mockJavascriptChannelRegistry,
          useHybridComposition: useHybridComposition ?? false,
        ),
      );

      return controllerCompleter.future;
    }

    testWidgets('Create Widget', (WidgetTester tester) async {
      await buildWidget(tester);

      verify(mockWebSettingsHostApi.setDomStorageEnabled(1, true));
      verify(mockWebSettingsHostApi.setJavaScriptCanOpenWindowsAutomatically(
        1,
        true,
      ));
      verify(mockWebSettingsHostApi.setSupportMultipleWindows(1, true));

      verifyInOrder([
        mockWebViewHostApi.create(0, false),
        mockWebViewHostApi.setWebViewClient(0, any),
        mockWebViewHostApi.setDownloadListener(0, any),
        mockWebViewHostApi.setWebChromeClient(0, any),
      ]);
    });

    testWidgets(
      'Create Widget with Hybrid Composition',
      (WidgetTester tester) async {
        await buildWidget(tester, useHybridComposition: true);
        verify(mockWebViewHostApi.create(0, true));
      },
    );

    group('CreationParams', () {
      testWidgets('initialUrl', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(initialUrl: 'https://www.google.com'),
        );
        verify(mockWebViewHostApi.loadUrl(
          0,
          'https://www.google.com',
          <String, String>{},
        ));
      });

      testWidgets('userAgent', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(userAgent: 'MyUserAgent'),
        );

        verify(mockWebSettingsHostApi.setUserAgentString(1, 'MyUserAgent'));
      });

      testWidgets('autoMediaPlaybackPolicy true', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy:
                AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          ),
        );

        verify(
          mockWebSettingsHostApi.setMediaPlaybackRequiresUserGesture(any, true),
        );
      });

      testWidgets('autoMediaPlaybackPolicy false', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          ),
        );

        verify(mockWebSettingsHostApi.setMediaPlaybackRequiresUserGesture(
          any,
          false,
        ));
      });

      testWidgets('javascriptChannelNames', (WidgetTester tester) async {
        await buildWidget(
          tester,
          creationParams: CreationParams(
            javascriptChannelNames: <String>{'a', 'b'},
          ),
        );

        verify(mockJavaScriptChannelHostApi.create(any, 'a'));
        verify(mockJavaScriptChannelHostApi.create(any, 'b'));
        verify(mockWebViewHostApi.addJavaScriptChannel(0, any)).called(2);
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

          verify(mockWebSettingsHostApi.setJavaScriptEnabled(any, true));
        });

        testWidgets('hasNavigationDelegate', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: WebSetting<String?>.absent(),
                hasNavigationDelegate: true,
              ),
            ),
          );

          verify(mockWebViewClientHostApi.create(any, true));
        });

        testWidgets('debuggingEnabled', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: WebSetting<String?>.absent(),
                debuggingEnabled: true,
              ),
            ),
          );

          verify(mockWebViewHostApi.setWebContentsDebuggingEnabled(true));
        });

        testWidgets('userAgent', (WidgetTester tester) async {
          await buildWidget(
            tester,
            creationParams: CreationParams(
              webSettings: WebSettings(
                userAgent: WebSetting<String?>.of('myUserAgent'),
              ),
            ),
          );

          verify(mockWebSettingsHostApi.setUserAgentString(any, 'myUserAgent'));
        });
      });
    });

    group('$AndroidWebViewPlatformController', () {
      testWidgets('loadUrl', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.loadUrl(
          'https://www.google.com',
          <String, String>{'a': 'header'},
        );

        verify(mockWebViewHostApi.loadUrl(
          any,
          'https://www.google.com',
          <String, String>{'a': 'header'},
        ));
      });

      testWidgets('currentUrl', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        when(mockWebViewHostApi.getUrl(any))
            .thenReturn('https://www.google.com');
        expect(controller.currentUrl(), completion('https://www.google.com'));
      });

      testWidgets('canGoBack', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        when(mockWebViewHostApi.canGoBack(any)).thenReturn(false);
        expect(controller.canGoBack(), completion(false));
      });

      testWidgets('canGoForward', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        when(mockWebViewHostApi.canGoForward(any)).thenReturn(true);
        expect(controller.canGoForward(), completion(true));
      });

      testWidgets('goBack', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.goBack();
        verify(mockWebViewHostApi.goBack(any));
      });

      testWidgets('goForward', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.goForward();
        verify(mockWebViewHostApi.goForward(any));
      });

      testWidgets('reload', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.reload();
        verify(mockWebViewHostApi.reload(any));
      });

      testWidgets('clearCache', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.clearCache();
        verify(mockWebViewHostApi.clearCache(any, true));
      });

      testWidgets('evaluateJavascript', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        when(mockWebViewHostApi.evaluateJavascript(any, 'runJavaScript'))
            .thenAnswer(
          (_) => Future<String>.value('returnString'),
        );
        expect(
          controller.evaluateJavascript('runJavaScript'),
          completion('returnString'),
        );
      });

      testWidgets('addJavascriptChannels', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.addJavascriptChannels(<String>{'c', 'd'});
        verify(mockJavaScriptChannelHostApi.create(any, 'c'));
        verify(mockJavaScriptChannelHostApi.create(any, 'd'));
        verify(mockWebViewHostApi.addJavaScriptChannel(0, any)).called(2);
      });

      testWidgets('removeJavascriptChannels', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.addJavascriptChannels(<String>{'c', 'd'});
        await controller.removeJavascriptChannels(<String>{'c', 'd'});
        verify(mockJavaScriptChannelHostApi.dispose(any)).called(2);
        verify(mockWebViewHostApi.removeJavaScriptChannel(0, any)).called(2);
      });

      testWidgets('getTitle', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        when(mockWebViewHostApi.getTitle(any)).thenReturn('Web Title');
        expect(controller.getTitle(), completion('Web Title'));
      });

      testWidgets('scrollTo', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.scrollTo(1, 2);
        verify(mockWebViewHostApi.scrollTo(any, 1, 2));
      });

      testWidgets('scrollBy', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        await controller.scrollBy(3, 4);
        verify(mockWebViewHostApi.scrollBy(any, 3, 4));
      });

      testWidgets('getScrollX', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        when(mockWebViewHostApi.getScrollX(any)).thenReturn(23);
        expect(controller.getScrollX(), completion(23));
      });

      testWidgets('getScrollY', (WidgetTester tester) async {
        final AndroidWebViewPlatformController controller =
            await buildWidget(tester);

        when(mockWebViewHostApi.getScrollY(any)).thenReturn(25);
        expect(controller.getScrollY(), completion(25));
      });
    });
  });
}
