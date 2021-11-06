// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_android/src/android_webview.dart';
import 'package:webview_flutter_android/src/android_webview_api_impls.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';

import 'android_webview.pigeon.dart';
import 'android_webview_test.mocks.dart';

@GenerateMocks([
  TestWebViewHostApi,
  TestWebSettingsHostApi,
  TestWebViewClientHostApi,
  TestWebChromeClientHostApi,
  TestJavaScriptChannelHostApi,
  TestDownloadListenerHostApi
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Android WebView', () {
    group('$WebView', () {
      late MockTestWebViewHostApi mockPlatformHostApi =
          MockTestWebViewHostApi();

      late InstanceManager testInstanceManager;
      late WebViewHostApiImpl testWebViewHostApi;

      late WebView testWebView;
      late int testWebViewInstanceId;

      setUp(() {
        mockPlatformHostApi = MockTestWebViewHostApi();
        TestWebViewHostApi.setup(mockPlatformHostApi);

        testInstanceManager = InstanceManager();
        testWebViewHostApi = WebViewHostApiImpl(
          instanceManager: testInstanceManager,
        );
        WebView.api = testWebViewHostApi;

        testWebView = WebView();
        testWebViewInstanceId = testInstanceManager.getInstanceId(testWebView)!;
      });

      test('create', () {
        verify(mockPlatformHostApi.create(testWebViewInstanceId, false));
      });

      test('setWebContentsDebuggingEnabled', () {
        WebView.setWebContentsDebuggingEnabled(true);
        verify(mockPlatformHostApi.setWebContentsDebuggingEnabled(true));
      });

      test('loadUrl', () {
        testWebView.loadUrl('hello', <String, String>{'a': 'header'});
        verify(mockPlatformHostApi.loadUrl(
          testWebViewInstanceId,
          'hello',
          <String, String>{'a': 'header'},
        ));
      });

      test('canGoBack', () {
        when(mockPlatformHostApi.canGoBack(testWebViewInstanceId))
            .thenReturn(false);
        expect(testWebView.canGoBack(), completion(false));
      });

      test('canGoForward', () {
        when(mockPlatformHostApi.canGoForward(testWebViewInstanceId))
            .thenReturn(true);
        expect(testWebView.canGoForward(), completion(true));
      });

      test('goBack', () {
        testWebView.goBack();
        verify(mockPlatformHostApi.goBack(testWebViewInstanceId));
      });

      test('goForward', () {
        testWebView.goForward();
        verify(mockPlatformHostApi.goForward(testWebViewInstanceId));
      });

      test('reload', () {
        testWebView.reload();
        verify(mockPlatformHostApi.reload(testWebViewInstanceId));
      });

      test('clearCache', () {
        testWebView.clearCache(false);
        verify(mockPlatformHostApi.clearCache(testWebViewInstanceId, false));
      });

      test('evaluateJavascript', () {
        when(
          mockPlatformHostApi.evaluateJavascript(
              testWebViewInstanceId, 'runJavaScript'),
        ).thenAnswer((_) => Future<String>.value('returnValue'));
        expect(
          testWebView.evaluateJavascript('runJavaScript'),
          completion('returnValue'),
        );
      });

      test('getTitle', () {
        when(mockPlatformHostApi.getTitle(testWebViewInstanceId))
            .thenReturn('aTitle');
        expect(testWebView.getTitle(), completion('aTitle'));
      });

      test('scrollTo', () {
        testWebView.scrollTo(12, 13);
        verify(mockPlatformHostApi.scrollTo(testWebViewInstanceId, 12, 13));
      });

      test('scrollBy', () {
        testWebView.scrollBy(12, 14);
        verify(mockPlatformHostApi.scrollBy(testWebViewInstanceId, 12, 14));
      });

      test('getScrollX', () {
        when(mockPlatformHostApi.getScrollX(testWebViewInstanceId))
            .thenReturn(67);
        expect(testWebView.getScrollX(), completion(67));
      });

      test('getScrollY', () {
        when(mockPlatformHostApi.getScrollY(testWebViewInstanceId))
            .thenReturn(56);
        expect(testWebView.getScrollY(), completion(56));
      });

      test('setWebViewClient', () {
        TestWebViewClientHostApi.setup(MockTestWebViewClientHostApi());
        WebViewClient.api = WebViewClientHostApiImpl(
          instanceManager: testInstanceManager,
        );

        final WebViewClient webViewClient =
            TestWebViewClient(shouldOverrideUrlLoading: false);
        testWebView.setWebViewClient(webViewClient);

        final int webViewClientInstanceId =
            testInstanceManager.getInstanceId(webViewClient)!;
        verify(mockPlatformHostApi.setWebViewClient(
          testWebViewInstanceId,
          webViewClientInstanceId,
        ));
      });

      test('addJavaScriptChannel', () {
        TestJavaScriptChannelHostApi.setup(MockTestJavaScriptChannelHostApi());
        JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
          instanceManager: testInstanceManager,
        );

        final JavaScriptChannel javaScriptChannel =
            TestJavaScriptChannel('jChannel');
        testWebView.addJavaScriptChannel(javaScriptChannel);

        final int javaScriptChannelInstanceId =
            testInstanceManager.getInstanceId(javaScriptChannel)!;
        verify(mockPlatformHostApi.addJavaScriptChannel(
          testWebViewInstanceId,
          javaScriptChannelInstanceId,
        ));
      });

      test('removeJavaScriptChannel', () {
        TestJavaScriptChannelHostApi.setup(MockTestJavaScriptChannelHostApi());
        JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
          instanceManager: testInstanceManager,
        );

        final JavaScriptChannel javaScriptChannel =
            TestJavaScriptChannel('jChannel');

        expect(
          testWebView.removeJavaScriptChannel(javaScriptChannel),
          completes,
        );

        testWebView.addJavaScriptChannel(javaScriptChannel);
        testWebView.removeJavaScriptChannel(javaScriptChannel);

        final int javaScriptChannelInstanceId =
            testInstanceManager.getInstanceId(javaScriptChannel)!;
        verify(mockPlatformHostApi.removeJavaScriptChannel(
          testWebViewInstanceId,
          javaScriptChannelInstanceId,
        ));
      });

      test('setDownloadListener', () {
        TestDownloadListenerHostApi.setup(MockTestDownloadListenerHostApi());
        DownloadListener.api = DownloadListenerHostApiImpl(
          instanceManager: testInstanceManager,
        );

        final DownloadListener downloadListener = TestDownloadListener();
        testWebView.setDownloadListener(downloadListener);

        final int downloadListenerInstanceId =
            testInstanceManager.getInstanceId(downloadListener)!;
        verify(mockPlatformHostApi.setDownloadListener(
          testWebViewInstanceId,
          downloadListenerInstanceId,
        ));
      });

      test('setWebChromeClient', () {
        // Setting a WebChromeClient requires setting a WebViewClient first.
        TestWebViewClientHostApi.setup(MockTestWebViewClientHostApi());
        WebViewClient.api = WebViewClientHostApiImpl(
          instanceManager: testInstanceManager,
        );
        final WebViewClient webViewClient =
            TestWebViewClient(shouldOverrideUrlLoading: false);
        testWebView.setWebViewClient(webViewClient);

        TestWebChromeClientHostApi.setup(MockTestWebChromeClientHostApi());
        WebChromeClient.api = WebChromeClientHostApiImpl(
          instanceManager: testInstanceManager,
        );

        final WebChromeClient webChromeClient = TestWebChromeClient();
        testWebView.setWebChromeClient(webChromeClient);

        final int webChromeClientInstanceId =
            testInstanceManager.getInstanceId(webChromeClient)!;
        verify(mockPlatformHostApi.setWebChromeClient(
          testWebViewInstanceId,
          webChromeClientInstanceId,
        ));
      });

      test('release', () {
        testWebView.release();
        verify(mockPlatformHostApi.dispose(testWebViewInstanceId));
      });
    });

    group('$WebSettings', () {
      setUpAll(() {
        TestWebViewHostApi.setup(MockTestWebViewHostApi());
        TestWebSettingsHostApi.setup(MockTestWebSettingsHostApi());
      });

      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);
        WebSettings.api = WebSettingsHostApiImpl(
          instanceManager: instanceManager,
        );
      });

      test('create', () {
        final WebView webView = WebView();
        final WebSettings webSettings = WebSettings(webView);
        expect(
          WebSettings.api.instanceManager.getInstanceId(webSettings),
          isNotNull,
        );
      });
    });

    group('$JavaScriptChannel', () {
      setUpAll(() {
        TestWebViewHostApi.setup(MockTestWebViewHostApi());
        TestJavaScriptChannelHostApi.setup(MockTestJavaScriptChannelHostApi());
      });

      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);
        JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
          instanceManager: instanceManager,
        );
      });

      test('create', () {
        final WebView webView = WebView();
        final JavaScriptChannel channel = TestJavaScriptChannel('myChannel');

        webView.addJavaScriptChannel(channel);
        expect(
          JavaScriptChannel.api.instanceManager.getInstanceId(channel),
          isNotNull,
        );
      });
    });

    group('$WebViewClient', () {
      setUpAll(() {
        TestWebViewHostApi.setup(MockTestWebViewHostApi());
        TestWebViewClientHostApi.setup(MockTestWebViewClientHostApi());
      });

      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);
        WebViewClient.api = WebViewClientHostApiImpl(
          instanceManager: instanceManager,
        );
      });

      test('create', () {
        final WebView webView = WebView();
        final WebViewClient webViewClient =
            TestWebViewClient(shouldOverrideUrlLoading: true);

        webView.setWebViewClient(webViewClient);
        expect(
          WebViewClient.api.instanceManager.getInstanceId(webViewClient),
          isNotNull,
        );
      });
    });

    group('$DownloadListener', () {
      setUpAll(() {
        TestWebViewHostApi.setup(MockTestWebViewHostApi());
        TestDownloadListenerHostApi.setup(MockTestDownloadListenerHostApi());
      });

      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);
        DownloadListener.api = DownloadListenerHostApiImpl(
          instanceManager: instanceManager,
        );
      });

      test('create', () {
        final WebView webView = WebView();
        final DownloadListener downloadListener = TestDownloadListener();

        webView.setDownloadListener(downloadListener);
        expect(
          DownloadListener.api.instanceManager.getInstanceId(downloadListener),
          isNotNull,
        );
      });
    });

    group('$WebChromeClient', () {
      setUpAll(() {
        TestWebViewHostApi.setup(MockTestWebViewHostApi());
        TestWebViewClientHostApi.setup(MockTestWebViewClientHostApi());
        TestWebChromeClientHostApi.setup(MockTestWebChromeClientHostApi());
      });

      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);
        WebViewClient.api = WebViewClientHostApiImpl(
          instanceManager: instanceManager,
        );
        WebChromeClient.api = WebChromeClientHostApiImpl(
          instanceManager: instanceManager,
        );
      });

      test('create', () {
        final WebView webView = WebView();
        webView.setWebViewClient(
            TestWebViewClient(shouldOverrideUrlLoading: true));

        final WebChromeClient webChromeClient = TestWebChromeClient();

        webView.setWebChromeClient(webChromeClient);
        expect(
          WebChromeClient.api.instanceManager.getInstanceId(webChromeClient),
          isNotNull,
        );
      });
    });
  });
}

class TestJavaScriptChannel extends JavaScriptChannel {
  TestJavaScriptChannel(String channelName) : super(channelName);

  @override
  void postMessage(String message) {}
}

class TestWebViewClient extends WebViewClient {
  TestWebViewClient({required bool shouldOverrideUrlLoading})
      : super(shouldOverrideUrlLoading: shouldOverrideUrlLoading);
}

class TestDownloadListener extends DownloadListener {
  @override
  void onDownloadStart(
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  ) {}
}

class TestWebChromeClient extends WebChromeClient {
  @override
  void onProgressChanged(WebView webView, int progress) {}
}
