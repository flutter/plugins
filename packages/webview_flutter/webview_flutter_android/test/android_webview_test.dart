// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_android/src/android_webview.dart';
import 'package:webview_flutter_android/src/android_webview_api_impls.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';

import 'test_binary_messenger.dart';

void main() {
  group('Android WebView', () {
    group('$WebView', () {
      setUp(() {
        WebView.api = WebViewHostApiImpl(
          instanceManager: InstanceManager(),
          binaryMessenger: TestBinaryMessenger(),
        );
      });

      tearDownAll(() {
        WebView.api = WebViewHostApiImpl();
      });

      test('create', () {
        final WebView webView = WebView();
        expect(WebView.api.instanceManager.getInstanceId(webView), isNotNull);
      });
    });

    group('$WebSettings', () {
      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        final TestBinaryMessenger binaryMessenger = TestBinaryMessenger();
        WebView.api = WebViewHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        );
        WebSettings.api = WebSettingsHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        );
      });

      test('create', () {
        final WebView webView = WebView();
        final WebSettings webSettings = webView.settings;
        expect(
          WebSettings.api.instanceManager.getInstanceId(webSettings),
          isNotNull,
        );
      });
    });

    group('$JavaScriptChannel', () {
      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        final TestBinaryMessenger binaryMessenger = TestBinaryMessenger();
        WebView.api = WebViewHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        );
        JavaScriptChannel.api = JavaScriptChannelHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
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
      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        final TestBinaryMessenger binaryMessenger = TestBinaryMessenger();
        WebView.api = WebViewHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        );
        WebViewClient.api = WebViewClientHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
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
      setUp(() {
        final InstanceManager instanceManager = InstanceManager();
        final TestBinaryMessenger binaryMessenger = TestBinaryMessenger();
        WebView.api = WebViewHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
        );
        DownloadListener.api = DownloadListenerHostApiImpl(
          instanceManager: instanceManager,
          binaryMessenger: binaryMessenger,
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
  });
}

class TestJavaScriptChannel extends JavaScriptChannel {
  TestJavaScriptChannel(String channelName) : super(channelName);

  @override
  void postMessage(String message) {
    // Do nothing.
  }
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
  ) {
    // Do nothing.
  }
}
