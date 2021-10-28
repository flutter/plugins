// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
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
      setUpAll(() {
        TestWebViewHostApi.setup(MockTestWebViewHostApi());
      });

      setUp(() {
        WebView.api = WebViewHostApiImpl(instanceManager: InstanceManager());
      });

      test('create', () {
        final WebView webView = WebView();
        expect(WebView.api.instanceManager.getInstanceId(webView), isNotNull);
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

        webView.removeJavaScriptChannel(channel);
        expect(
          JavaScriptChannel.api.instanceManager.getInstanceId(channel),
          isNull,
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
        final WebViewClient webViewClient1 = TestWebViewClient();
        final WebViewClient webViewClient2 = TestWebViewClient();

        webView.setWebViewClient(webViewClient1);
        expect(
          WebViewClient.api.instanceManager.getInstanceId(webViewClient1),
          isNotNull,
        );

        webView.setWebViewClient(webViewClient2);
        expect(
          WebViewClient.api.instanceManager.getInstanceId(webViewClient1),
          isNull,
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
        final DownloadListener downloadListener1 = TestDownloadListener();
        final DownloadListener downloadListener2 = TestDownloadListener();

        webView.setDownloadListener(downloadListener1);
        expect(
          DownloadListener.api.instanceManager.getInstanceId(downloadListener1),
          isNotNull,
        );

        webView.setDownloadListener(downloadListener2);
        expect(
          DownloadListener.api.instanceManager.getInstanceId(downloadListener1),
          isNull,
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
        webView.setWebViewClient(TestWebViewClient());

        final WebChromeClient webChromeClient1 = TestWebChromeClient();
        final WebChromeClient webChromeClient2 = TestWebChromeClient();

        webView.setWebChromeClient(webChromeClient1);
        expect(
          WebChromeClient.api.instanceManager.getInstanceId(webChromeClient1),
          isNotNull,
        );

        webView.setWebChromeClient(webChromeClient2);
        expect(
          WebChromeClient.api.instanceManager.getInstanceId(webChromeClient1),
          isNull,
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

class TestWebViewClient extends WebViewClient {}

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
