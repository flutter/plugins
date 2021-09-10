// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;

public class FlutterWebViewTest {
  private WebChromeClient mockWebChromeClient;
  private DownloadListener mockDownloadListener;
  private WebViewBuilder mockWebViewBuilder;
  private WebView mockWebView;

  @Before
  public void before() {
    mockWebChromeClient = mock(WebChromeClient.class);
    mockWebViewBuilder = mock(WebViewBuilder.class);
    mockWebView = mock(WebView.class);
    mockDownloadListener = mock(DownloadListener.class);

    when(mockWebViewBuilder.setDomStorageEnabled(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setJavaScriptCanOpenWindowsAutomatically(anyBoolean()))
        .thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setSupportMultipleWindows(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setUsesHybridComposition(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setWebChromeClient(any(WebChromeClient.class)))
        .thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setDownloadListener(any(DownloadListener.class)))
        .thenReturn(mockWebViewBuilder);

    when(mockWebViewBuilder.build()).thenReturn(mockWebView);
  }

  @Test
  public void createWebView_should_create_webview_with_default_configuration() {
    FlutterWebView.createWebView(
        mockWebViewBuilder, createParameterMap(false), mockWebChromeClient, mockDownloadListener);

    verify(mockWebViewBuilder, times(1)).setDomStorageEnabled(true);
    verify(mockWebViewBuilder, times(1)).setJavaScriptCanOpenWindowsAutomatically(true);
    verify(mockWebViewBuilder, times(1)).setSupportMultipleWindows(true);
    verify(mockWebViewBuilder, times(1)).setUsesHybridComposition(false);
    verify(mockWebViewBuilder, times(1)).setWebChromeClient(mockWebChromeClient);
  }

  private Map<String, Object> createParameterMap(boolean usesHybridComposition) {
    Map<String, Object> params = new HashMap<>();
    params.put("usesHybridComposition", usesHybridComposition);

    return params;
  }
}
