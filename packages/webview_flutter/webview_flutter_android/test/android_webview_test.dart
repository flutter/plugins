// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_android/src/android_webview.dart';
import 'package:webview_flutter_android/src/android_webview_api_impls.dart';
import 'package:webview_flutter_android/src/instance_manager.dart';

import 'android_webview.pigeon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Android WebView', () {
    group('$WebView', () {
      setUpAll(() {
        TestWebViewHostApi.setup(TestWebViewHostApiImpl());
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
        TestWebViewHostApi.setup(TestWebViewHostApiImpl());
        TestWebSettingsHostApi.setup(TestWebSettingsHostApiImpl());
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
        TestWebViewHostApi.setup(TestWebViewHostApiImpl());
        TestJavaScriptChannelHostApi.setup(TestJavaScriptChannelHostApiImpl());
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
        TestWebViewHostApi.setup(TestWebViewHostApiImpl());
        TestWebViewClientHostApi.setup(TestWebViewClientHostApiImpl());
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
        TestWebViewHostApi.setup(TestWebViewHostApiImpl());
        TestDownloadListenerHostApi.setup(TestDownloadListenerHostApiImpl());
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
        TestWebViewHostApi.setup(TestWebViewHostApiImpl());
        TestWebViewClientHostApi.setup(TestWebViewClientHostApiImpl());
        TestWebChromeClientHostApi.setup(TestWebChromeClientHostApiImpl());
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

class TestWebViewHostApiImpl extends TestWebViewHostApi {
  @override
  void addJavaScriptChannel(int instanceId, int javaScriptChannelInstanceId) {}

  @override
  bool canGoBack(int instanceId) {
    throw UnimplementedError();
  }

  @override
  bool canGoForward(int instanceId) {
    throw UnimplementedError();
  }

  @override
  void clearCache(int instanceId, bool includeDiskFiles) {}

  @override
  void create(int instanceId, bool useHybridComposition) {}

  @override
  void dispose(int instanceId) {}

  @override
  Future<String> evaluateJavascript(int instanceId, String javascriptString) {
    throw UnimplementedError();
  }

  @override
  int getScrollX(int instanceId) {
    throw UnimplementedError();
  }

  @override
  int getScrollY(int instanceId) {
    throw UnimplementedError();
  }

  @override
  String getTitle(int instanceId) {
    throw UnimplementedError();
  }

  @override
  String getUrl(int instanceId) {
    throw UnimplementedError();
  }

  @override
  void goBack(int instanceId) {}

  @override
  void goForward(int instanceId) {}

  @override
  void loadUrl(int instanceId, String url, Map headers) {}

  @override
  void reload(int instanceId) {}

  @override
  void removeJavaScriptChannel(
      int instanceId, int javaScriptChannelInstanceId) {}

  @override
  void scrollBy(int instanceId, int x, int y) {}

  @override
  void scrollTo(int instanceId, int x, int y) {}

  @override
  void setDownloadListener(int instanceId, int listenerInstanceId) {}

  @override
  void setWebContentsDebuggingEnabled(bool enabled) {}

  @override
  void setWebViewClient(int instanceId, int webViewClientInstanceId) {}

  @override
  void setWebChromeClient(int instanceId, int clientInstanceId) {}
}

class TestWebSettingsHostApiImpl extends TestWebSettingsHostApi {
  @override
  void create(int instanceId, int webViewInstanceId) {}

  @override
  void dispose(int instanceId) {}

  @override
  void setBuiltInZoomControls(int instanceId, bool enabled) {}

  @override
  void setDisplayZoomControls(int instanceId, bool enabled) {}

  @override
  void setDomStorageEnabled(int instanceId, bool flag) {}

  @override
  void setJavaScriptCanOpenWindowsAutomatically(int instanceId, bool flag) {}

  @override
  void setJavaScriptEnabled(int instanceId, bool flag) {}

  @override
  void setLoadWithOverviewMode(int instanceId, bool overview) {}

  @override
  void setMediaPlaybackRequiresUserGesture(int instanceId, bool require) {}

  @override
  void setSupportMultipleWindows(int instanceId, bool support) {}

  @override
  void setSupportZoom(int instanceId, bool support) {}

  @override
  void setUseWideViewPort(int instanceId, bool use) {}

  @override
  void setUserAgentString(int instanceId, String userAgentString) {}
}

class TestJavaScriptChannelHostApiImpl extends TestJavaScriptChannelHostApi {
  @override
  void create(int instanceId, String channelName) {}

  @override
  void dispose(int instanceId) {}
}

class TestWebViewClientHostApiImpl extends TestWebViewClientHostApi {
  @override
  void create(int instanceId, bool shouldOverrideUrlLoading) {}

  @override
  void dispose(int instanceId) {}
}

class TestDownloadListenerHostApiImpl extends TestDownloadListenerHostApi {
  @override
  void create(int instanceId) {}

  @override
  void dispose(int instanceId) {}
}

class TestWebChromeClientHostApiImpl extends TestWebChromeClientHostApi {
  @override
  void create(int instanceId, int webViewClientInstanceId) {}

  @override
  void dispose(int instanceId) {}
}
