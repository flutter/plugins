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

  void loadData(
    int instanceId,
    String data,
    String mimeType,
    String encoding,
  );

  void loadDataWithBaseUrl(
    int instanceId,
    String baseUrl,
    String data,
    String mimeType,
    String encoding,
    String historyUrl,
  );

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

  void setWebChromeClient(int instanceId, int clientInstanceId);

  void setBackgroundColor(int instanceId, int color);
}

@HostApi(dartHostTestHandler: 'TestWebSettingsHostApi')
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

@HostApi(dartHostTestHandler: 'TestJavaScriptChannelHostApi')
abstract class JavaScriptChannelHostApi {
  void create(int instanceId, String channelName);
}

@FlutterApi()
abstract class JavaScriptChannelFlutterApi {
  void dispose(int instanceId);

  void postMessage(int instanceId, String message);
}

@HostApi(dartHostTestHandler: 'TestWebViewClientHostApi')
abstract class WebViewClientHostApi {
  void create(int instanceId, bool shouldOverrideUrlLoading);
}

@FlutterApi()
abstract class WebViewClientFlutterApi {
  void dispose(int instanceId);

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

@HostApi(dartHostTestHandler: 'TestDownloadListenerHostApi')
abstract class DownloadListenerHostApi {
  void create(int instanceId);
}

@FlutterApi()
abstract class DownloadListenerFlutterApi {
  void dispose(int instanceId);

  void onDownloadStart(
    int instanceId,
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  );
}

@HostApi(dartHostTestHandler: 'TestWebChromeClientHostApi')
abstract class WebChromeClientHostApi {
  void create(int instanceId, int webViewClientInstanceId);
}

@HostApi(dartHostTestHandler: 'TestAssetManagerHostApi')
abstract class FlutterAssetManagerHostApi {
  List<String> list(String path);

  String getAssetFilePathByName(String name);
}

@FlutterApi()
abstract class WebChromeClientFlutterApi {
  void dispose(int instanceId);

  void onProgressChanged(int instanceId, int webViewInstanceId, int progress);
}
