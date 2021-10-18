// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class WebResourceRequestData {
  String? url;
  bool? isForMainFrame;
  bool? isRedirect;
  bool? hasGesture;
  String? method;
  Map<String?, String?>? requestHeaders;
}

class WebResourceErrorData {
  int? errorCode;
  String? description;
}

@HostApi(dartHostTestHandler: 'TestWebViewHostApi')
abstract class WebViewHostApi {
  void create(int instanceId, bool useHybridComposition);

  void dispose(int instanceId);

  void loadUrl(
    int instanceId,
    String url,
    Map<String, String> headers,
  );

  String getUrl(int instanceId);

  bool canGoBack(int instanceId);

  bool canGoForward(int instanceId);

  void goBack(int instanceId);

  void goForward(int instanceId);

  void reload(int instanceId);

  void clearCache(int instanceId, bool includeDiskFiles);

  @async
  String evaluateJavascript(
    int instanceId,
    String javascriptString,
  );

  String getTitle(int instanceId);

  void scrollTo(int instanceId, int x, int y);

  void scrollBy(int instanceId, int x, int y);

  int getScrollX(int instanceId);

  int getScrollY(int instanceId);

  void setWebContentsDebuggingEnabled(bool enabled);

  void setWebViewClient(int instanceId, int webViewClientInstanceId);

  void addJavaScriptChannel(int instanceId, int javaScriptChannelInstanceId);

  void removeJavaScriptChannel(int instanceId, int javaScriptChannelInstanceId);

  void setDownloadListener(int instanceId, int listenerInstanceId);
}

@HostApi()
abstract class WebSettingsHostApi {
  void create(int instanceId, int webViewInstanceId);

  void dispose(int instanceId);

  void setDomStorageEnabled(int instanceId, bool flag);

  void setJavaScriptCanOpenWindowsAutomatically(int instanceId, bool flag);

  void setSupportMultipleWindows(int instanceId, bool support);

  void setJavaScriptEnabled(int instanceId, bool flag);

  void setUserAgentString(int instanceId, String userAgentString);

  void setMediaPlaybackRequiresUserGesture(int instanceId, bool require);

  void setSupportZoom(int instanceId, bool support);

  void setLoadWithOverviewMode(int instanceId, bool overview);

  void setUseWideViewPort(int instanceId, bool use);

  void setDisplayZoomControls(int instanceId, bool enabled);

  void setBuiltInZoomControls(int instanceId, bool enabled);
}

@HostApi()
abstract class JavaScriptChannelHostApi {
  void create(int instanceId, String channelName);

  void dispose(int instanceId);
}

@FlutterApi()
abstract class JavaScriptChannelFlutterApi {
  void postMessage(int instanceId, String message);
}

@HostApi()
abstract class WebViewClientHostApi {
  void create(int instanceId, bool shouldOverrideUrlLoading);

  void dispose(int instanceId);
}

@FlutterApi()
abstract class WebViewClientFlutterApi {
  void onPageStarted(int instanceId, int webViewInstanceId, String url);

  void onPageFinished(int instanceId, int webViewInstanceId, String url);

  void onReceivedRequestError(
    int instanceId,
    int webViewInstanceId,
    WebResourceRequestData request,
    WebResourceErrorData error,
  );

  void onReceivedError(
    int instanceId,
    int webViewInstanceId,
    int errorCode,
    String description,
    String failingUrl,
  );

  void requestLoading(
    int instanceId,
    int webViewInstanceId,
    WebResourceRequestData request,
  );

  void urlLoading(int instanceId, int webViewInstanceId, String url);
}

@HostApi()
abstract class DownloadListenerHostApi {
  void create(int instanceId);
  void dispose(int instanceId);
}

@FlutterApi()
abstract class DownloadListenerFlutterApi {
  void onDownloadStart(
    int instanceId,
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  );
}
