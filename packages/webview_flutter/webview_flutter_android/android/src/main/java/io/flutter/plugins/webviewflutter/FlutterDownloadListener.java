// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.DownloadListener;
import android.webkit.WebView;

/** DownloadListener to notify the {@link FlutterWebViewClient} of download starts */
public class FlutterDownloadListener implements DownloadListener {
  private final FlutterWebViewClient webViewClient;
  private WebView webView;

  public FlutterDownloadListener(FlutterWebViewClient webViewClient) {
    this.webViewClient = webViewClient;
  }

  /** Sets the {@link WebView} that the result of the navigation delegate will be send to. */
  public void setWebView(WebView webView) {
    this.webView = webView;
  }

  @Override
  public void onDownloadStart(
      String url,
      String userAgent,
      String contentDisposition,
      String mimetype,
      long contentLength) {
    webViewClient.notifyDownload(webView, url);
  }
}
