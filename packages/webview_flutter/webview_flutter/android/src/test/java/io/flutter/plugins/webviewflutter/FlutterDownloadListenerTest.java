// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.nullable;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.webkit.WebView;
import org.junit.Before;
import org.junit.Test;

public class FlutterDownloadListenerTest {
  private FlutterWebViewClient webViewClient;
  private WebView webView;

  @Before
  public void before() {
    webViewClient = mock(FlutterWebViewClient.class);
    webView = mock(WebView.class);
  }

  @Test
  public void onDownloadStart_should_notify_webViewClient() {
    String url = "testurl.com";
    FlutterDownloadListener downloadListener = new FlutterDownloadListener(webViewClient);
    downloadListener.onDownloadStart(url, "test", "inline", "data/text", 0);
    verify(webViewClient).notifyDownload(nullable(WebView.class), eq(url));
  }

  @Test
  public void onDownloadStart_should_pass_webView() {
    FlutterDownloadListener downloadListener = new FlutterDownloadListener(webViewClient);
    downloadListener.setWebView(webView);
    downloadListener.onDownloadStart("testurl.com", "test", "inline", "data/text", 0);
    verify(webViewClient).notifyDownload(eq(webView), anyString());
  }
}
