// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/annotations.dart';

import 'android_webview.pigeon.dart';

import 'test_android_webview_api_impls.mocks.dart';

@GenerateMocks([
  TestWebViewHostApi,
  TestWebSettingsHostApi,
  TestWebViewClientHostApi,
  TestWebChromeClientHostApi,
  TestJavaScriptChannelHostApi,
  TestDownloadListenerHostApi,
])
void main() {}

class TestWebViewHostApiImpl extends TestWebViewHostApi {
  final TestWebViewHostApi mock = MockTestWebViewHostApi();

  @override
  void addJavaScriptChannel(int instanceId, int javaScriptChannelInstanceId) {
    mock.addJavaScriptChannel(instanceId, javaScriptChannelInstanceId);
  }

  @override
  bool canGoBack(int instanceId) {
    return mock.canGoBack(instanceId);
  }

  @override
  bool canGoForward(int instanceId) {
    return mock.canGoForward(instanceId);
  }

  @override
  void clearCache(int instanceId, bool includeDiskFiles) {
    mock.clearCache(instanceId, includeDiskFiles);
  }

  @override
  void create(int instanceId, bool useHybridComposition) {
    mock.create(instanceId, useHybridComposition);
  }

  @override
  void dispose(int instanceId) {
    mock.dispose(instanceId);
  }

  @override
  Future<String> evaluateJavascript(int instanceId, String javascriptString) {
    return mock.evaluateJavascript(instanceId, javascriptString);
  }

  @override
  int getScrollX(int instanceId) {
    return mock.getScrollX(instanceId);
  }

  @override
  int getScrollY(int instanceId) {
    return mock.getScrollY(instanceId);
  }

  @override
  String getTitle(int instanceId) {
    return mock.getTitle(instanceId);
  }

  @override
  String getUrl(int instanceId) {
    return mock.getUrl(instanceId);
  }

  @override
  void goBack(int instanceId) {
    mock.goBack(instanceId);
  }

  @override
  void goForward(int instanceId) {
    mock.goForward(instanceId);
  }

  @override
  void loadUrl(int instanceId, String url, Map headers) {
    mock.loadUrl(instanceId, url, headers.cast<String?, String?>());
  }

  @override
  void reload(int instanceId) {
    mock.reload(instanceId);
  }

  @override
  void removeJavaScriptChannel(
    int instanceId,
    int javaScriptChannelInstanceId,
  ) {
    mock.removeJavaScriptChannel(instanceId, javaScriptChannelInstanceId);
  }

  @override
  void scrollBy(int instanceId, int x, int y) {
    mock.scrollBy(instanceId, x, y);
  }

  @override
  void scrollTo(int instanceId, int x, int y) {
    mock.scrollTo(instanceId, x, y);
  }

  @override
  void setDownloadListener(int instanceId, int listenerInstanceId) {
    mock.setDownloadListener(instanceId, listenerInstanceId);
  }

  @override
  void setWebContentsDebuggingEnabled(bool enabled) {
    mock.setWebContentsDebuggingEnabled(enabled);
  }

  @override
  void setWebViewClient(int instanceId, int webViewClientInstanceId) {
    mock.setWebViewClient(instanceId, webViewClientInstanceId);
  }

  @override
  void setWebChromeClient(int instanceId, int clientInstanceId) {
    mock.setWebChromeClient(instanceId, clientInstanceId);
  }
}

class TestWebSettingsHostApiImpl extends TestWebSettingsHostApi {
  final TestWebSettingsHostApi mock = MockTestWebSettingsHostApi();

  @override
  void create(int instanceId, int webViewInstanceId) {
    mock.create(instanceId, webViewInstanceId);
  }

  @override
  void dispose(int instanceId) {
    mock.dispose(instanceId);
  }

  @override
  void setBuiltInZoomControls(int instanceId, bool enabled) {
    mock.setBuiltInZoomControls(instanceId, enabled);
  }

  @override
  void setDisplayZoomControls(int instanceId, bool enabled) {
    mock.setDisplayZoomControls(instanceId, enabled);
  }

  @override
  void setDomStorageEnabled(int instanceId, bool flag) {
    mock.setDomStorageEnabled(instanceId, flag);
  }

  @override
  void setJavaScriptCanOpenWindowsAutomatically(int instanceId, bool flag) {
    mock.setJavaScriptCanOpenWindowsAutomatically(instanceId, flag);
  }

  @override
  void setJavaScriptEnabled(int instanceId, bool flag) {
    mock.setJavaScriptEnabled(instanceId, flag);
  }

  @override
  void setLoadWithOverviewMode(int instanceId, bool overview) {
    mock.setLoadWithOverviewMode(instanceId, overview);
  }

  @override
  void setMediaPlaybackRequiresUserGesture(int instanceId, bool require) {
    mock.setMediaPlaybackRequiresUserGesture(instanceId, require);
  }

  @override
  void setSupportMultipleWindows(int instanceId, bool support) {
    mock.setSupportMultipleWindows(instanceId, support);
  }

  @override
  void setSupportZoom(int instanceId, bool support) {
    mock.setSupportZoom(instanceId, support);
  }

  @override
  void setUseWideViewPort(int instanceId, bool use) {
    mock.setUseWideViewPort(instanceId, use);
  }

  @override
  void setUserAgentString(int instanceId, String userAgentString) {
    mock.setUserAgentString(instanceId, userAgentString);
  }
}

class TestJavaScriptChannelHostApiImpl extends TestJavaScriptChannelHostApi {
  final TestJavaScriptChannelHostApi mock = MockTestJavaScriptChannelHostApi();

  @override
  void create(int instanceId, String channelName) {
    mock.create(instanceId, channelName);
  }

  @override
  void dispose(int instanceId) {
    mock.dispose(instanceId);
  }
}

class TestWebViewClientHostApiImpl extends TestWebViewClientHostApi {
  final TestWebViewClientHostApi mock = MockTestWebViewClientHostApi();

  @override
  void create(int instanceId, bool shouldOverrideUrlLoading) {
    mock.create(instanceId, shouldOverrideUrlLoading);
  }

  @override
  void dispose(int instanceId) {
    mock.dispose(instanceId);
  }
}

class TestDownloadListenerHostApiImpl extends TestDownloadListenerHostApi {
  final TestDownloadListenerHostApi mock = MockTestDownloadListenerHostApi();

  @override
  void create(int instanceId) {
    mock.create(instanceId);
  }

  @override
  void dispose(int instanceId) {
    mock.dispose(instanceId);
  }
}

class TestWebChromeClientHostApiImpl extends TestWebChromeClientHostApi {
  final TestWebChromeClientHostApi mock = MockTestWebChromeClientHostApi();

  @override
  void create(int instanceId, int webViewClientInstanceId) {
    mock.create(instanceId, webViewClientInstanceId);
  }

  @override
  void dispose(int instanceId) {
    mock.dispose(instanceId);
  }
}
