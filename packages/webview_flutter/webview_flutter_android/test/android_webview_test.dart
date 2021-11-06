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
  DownloadListener,
  JavaScriptChannel,
  TestDownloadListenerHostApi,
  TestJavaScriptChannelHostApi,
  TestWebChromeClientHostApi,
  TestWebSettingsHostApi,
  TestWebViewClientHostApi,
  TestWebViewHostApi,
  WebChromeClient,
  WebViewClient,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Android WebView', () {
    group('$WebView', () {
      late MockTestWebViewHostApi mockPlatformHostApi;

      late InstanceManager instanceManager;

      late WebView webView;
      late int webViewInstanceId;

      setUp(() {
        mockPlatformHostApi = MockTestWebViewHostApi();
        TestWebViewHostApi.setup(mockPlatformHostApi);

        instanceManager = InstanceManager();
        WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);

        webView = WebView();
        webViewInstanceId = instanceManager.getInstanceId(webView)!;
      });

      test('create', () {
        verify(mockPlatformHostApi.create(webViewInstanceId, false));
      });

      test('setWebContentsDebuggingEnabled', () {
        WebView.setWebContentsDebuggingEnabled(true);
        verify(mockPlatformHostApi.setWebContentsDebuggingEnabled(true));
      });

      test('loadUrl', () {
        webView.loadUrl('hello', <String, String>{'a': 'header'});
        verify(mockPlatformHostApi.loadUrl(
          webViewInstanceId,
          'hello',
          <String, String>{'a': 'header'},
        ));
      });

      test('canGoBack', () {
        when(mockPlatformHostApi.canGoBack(webViewInstanceId))
            .thenReturn(false);
        expect(webView.canGoBack(), completion(false));
      });

      test('canGoForward', () {
        when(mockPlatformHostApi.canGoForward(webViewInstanceId))
            .thenReturn(true);
        expect(webView.canGoForward(), completion(true));
      });

      test('goBack', () {
        webView.goBack();
        verify(mockPlatformHostApi.goBack(webViewInstanceId));
      });

      test('goForward', () {
        webView.goForward();
        verify(mockPlatformHostApi.goForward(webViewInstanceId));
      });

      test('reload', () {
        webView.reload();
        verify(mockPlatformHostApi.reload(webViewInstanceId));
      });

      test('clearCache', () {
        webView.clearCache(false);
        verify(mockPlatformHostApi.clearCache(webViewInstanceId, false));
      });

      test('evaluateJavascript', () {
        when(
          mockPlatformHostApi.evaluateJavascript(
              webViewInstanceId, 'runJavaScript'),
        ).thenAnswer((_) => Future<String>.value('returnValue'));
        expect(
          webView.evaluateJavascript('runJavaScript'),
          completion('returnValue'),
        );
      });

      test('getTitle', () {
        when(mockPlatformHostApi.getTitle(webViewInstanceId))
            .thenReturn('aTitle');
        expect(webView.getTitle(), completion('aTitle'));
      });

      test('scrollTo', () {
        webView.scrollTo(12, 13);
        verify(mockPlatformHostApi.scrollTo(webViewInstanceId, 12, 13));
      });

      test('scrollBy', () {
        webView.scrollBy(12, 14);
        verify(mockPlatformHostApi.scrollBy(webViewInstanceId, 12, 14));
      });

      test('getScrollX', () {
        when(mockPlatformHostApi.getScrollX(webViewInstanceId)).thenReturn(67);
        expect(webView.getScrollX(), completion(67));
      });

      test('getScrollY', () {
        when(mockPlatformHostApi.getScrollY(webViewInstanceId)).thenReturn(56);
        expect(webView.getScrollY(), completion(56));
      });

      test('setWebViewClient', () {
        TestWebViewClientHostApi.setup(MockTestWebViewClientHostApi());
        WebViewClient.api = WebViewClientHostApiImpl(
          instanceManager: instanceManager,
        );

        final WebViewClient webViewClient =
            TestWebViewClient(shouldOverrideUrlLoading: false);
        webView.setWebViewClient(webViewClient);

        final int webViewClientInstanceId =
            instanceManager.getInstanceId(webViewClient)!;
        verify(mockPlatformHostApi.setWebViewClient(
          webViewInstanceId,
          webViewClientInstanceId,
        ));
      });

      test('addJavaScriptChannel', () {
        TestJavaScriptChannelHostApi.setup(MockTestJavaScriptChannelHostApi());
        JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
          instanceManager: instanceManager,
        );

        final JavaScriptChannel mockJavaScriptChannel = MockJavaScriptChannel();
        when(mockJavaScriptChannel.channelName).thenReturn('aChannel');

        webView.addJavaScriptChannel(mockJavaScriptChannel);

        final int javaScriptChannelInstanceId =
            instanceManager.getInstanceId(mockJavaScriptChannel)!;
        verify(mockPlatformHostApi.addJavaScriptChannel(
          webViewInstanceId,
          javaScriptChannelInstanceId,
        ));
      });

      test('removeJavaScriptChannel', () {
        TestJavaScriptChannelHostApi.setup(MockTestJavaScriptChannelHostApi());
        JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
          instanceManager: instanceManager,
        );

        final JavaScriptChannel mockJavaScriptChannel = MockJavaScriptChannel();
        when(mockJavaScriptChannel.channelName).thenReturn('aChannel');

        expect(
          webView.removeJavaScriptChannel(mockJavaScriptChannel),
          completes,
        );

        webView.addJavaScriptChannel(mockJavaScriptChannel);
        webView.removeJavaScriptChannel(mockJavaScriptChannel);

        final int javaScriptChannelInstanceId =
            instanceManager.getInstanceId(mockJavaScriptChannel)!;
        verify(mockPlatformHostApi.removeJavaScriptChannel(
          webViewInstanceId,
          javaScriptChannelInstanceId,
        ));
      });

      test('setDownloadListener', () {
        TestDownloadListenerHostApi.setup(MockTestDownloadListenerHostApi());
        DownloadListener.api = DownloadListenerHostApiImpl(
          instanceManager: instanceManager,
        );

        final DownloadListener downloadListener = TestDownloadListener();
        webView.setDownloadListener(downloadListener);

        final int downloadListenerInstanceId =
            instanceManager.getInstanceId(downloadListener)!;
        verify(mockPlatformHostApi.setDownloadListener(
          webViewInstanceId,
          downloadListenerInstanceId,
        ));
      });

      test('setWebChromeClient', () {
        // Setting a WebChromeClient requires setting a WebViewClient first.
        TestWebViewClientHostApi.setup(MockTestWebViewClientHostApi());
        WebViewClient.api = WebViewClientHostApiImpl(
          instanceManager: instanceManager,
        );
        final WebViewClient webViewClient =
            TestWebViewClient(shouldOverrideUrlLoading: false);
        webView.setWebViewClient(webViewClient);

        TestWebChromeClientHostApi.setup(MockTestWebChromeClientHostApi());
        WebChromeClient.api = WebChromeClientHostApiImpl(
          instanceManager: instanceManager,
        );

        final WebChromeClient webChromeClient = TestWebChromeClient();
        webView.setWebChromeClient(webChromeClient);

        final int webChromeClientInstanceId =
            instanceManager.getInstanceId(webChromeClient)!;
        verify(mockPlatformHostApi.setWebChromeClient(
          webViewInstanceId,
          webChromeClientInstanceId,
        ));
      });

      test('release', () {
        webView.release();
        verify(mockPlatformHostApi.dispose(webViewInstanceId));
      });
    });

    group('$WebSettings', () {
      late MockTestWebSettingsHostApi mockPlatformHostApi;

      late InstanceManager instanceManager;

      late WebSettings webSettings;
      late int webSettingsInstanceId;

      setUp(() {
        instanceManager = InstanceManager();

        TestWebViewHostApi.setup(MockTestWebViewHostApi());
        WebView.api = WebViewHostApiImpl(instanceManager: instanceManager);

        mockPlatformHostApi = MockTestWebSettingsHostApi();
        TestWebSettingsHostApi.setup(mockPlatformHostApi);

        WebSettings.api = WebSettingsHostApiImpl(
          instanceManager: instanceManager,
        );

        webSettings = WebSettings(WebView());
        webSettingsInstanceId = instanceManager.getInstanceId(webSettings)!;
      });

      test('create', () {
        verify(mockPlatformHostApi.create(webSettingsInstanceId, any));
      });

      test('setDomStorageEnabled', () {
        webSettings.setDomStorageEnabled(false);
        verify(mockPlatformHostApi.setDomStorageEnabled(
          webSettingsInstanceId,
          false,
        ));
      });

      test('setJavaScriptCanOpenWindowsAutomatically', () {
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        verify(mockPlatformHostApi.setJavaScriptCanOpenWindowsAutomatically(
          webSettingsInstanceId,
          true,
        ));
      });

      test('setSupportMultipleWindows', () {
        webSettings.setSupportMultipleWindows(false);
        verify(mockPlatformHostApi.setSupportMultipleWindows(
          webSettingsInstanceId,
          false,
        ));
      });

      test('setJavaScriptEnabled', () {
        webSettings.setJavaScriptEnabled(true);
        verify(mockPlatformHostApi.setJavaScriptEnabled(
          webSettingsInstanceId,
          true,
        ));
      });

      test('setUserAgentString', () {
        webSettings.setUserAgentString('hola');
        verify(mockPlatformHostApi.setUserAgentString(
          webSettingsInstanceId,
          'hola',
        ));
      });

      test('setMediaPlaybackRequiresUserGesture', () {
        webSettings.setMediaPlaybackRequiresUserGesture(false);
        verify(mockPlatformHostApi.setMediaPlaybackRequiresUserGesture(
          webSettingsInstanceId,
          false,
        ));
      });

      test('setSupportZoom', () {
        webSettings.setSupportZoom(true);
        verify(mockPlatformHostApi.setSupportZoom(
          webSettingsInstanceId,
          true,
        ));
      });

      test('setLoadWithOverviewMode', () {
        webSettings.setLoadWithOverviewMode(false);
        verify(mockPlatformHostApi.setLoadWithOverviewMode(
          webSettingsInstanceId,
          false,
        ));
      });

      test('setUseWideViewPort', () {
        webSettings.setUseWideViewPort(true);
        verify(mockPlatformHostApi.setUseWideViewPort(
          webSettingsInstanceId,
          true,
        ));
      });

      test('setDisplayZoomControls', () {
        webSettings.setDisplayZoomControls(false);
        verify(mockPlatformHostApi.setDisplayZoomControls(
          webSettingsInstanceId,
          false,
        ));
      });

      test('setBuiltInZoomControls', () {
        webSettings.setBuiltInZoomControls(true);
        verify(mockPlatformHostApi.setBuiltInZoomControls(
          webSettingsInstanceId,
          true,
        ));
      });
    });

    group('$JavaScriptChannel', () {
      late JavaScriptChannelFlutterApiImpl flutterApi;

      late InstanceManager instanceManager;

      late MockJavaScriptChannel mockJavaScriptChannel;
      late int mockJavaScriptChannelInstanceId;

      setUp(() {
        instanceManager = InstanceManager();
        flutterApi = JavaScriptChannelFlutterApiImpl(
          instanceManager: instanceManager,
        );

        mockJavaScriptChannel = MockJavaScriptChannel();
        mockJavaScriptChannelInstanceId =
            instanceManager.tryAddInstance(mockJavaScriptChannel)!;
      });

      test('postMessage', () {
        flutterApi.postMessage(
          mockJavaScriptChannelInstanceId,
          'Hello, World!',
        );
        verify(mockJavaScriptChannel.postMessage('Hello, World!'));
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
