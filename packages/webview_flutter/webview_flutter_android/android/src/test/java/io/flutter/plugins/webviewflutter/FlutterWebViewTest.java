// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.webkit.DownloadListener;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.MethodChannel;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class FlutterWebViewTest {
  private WebChromeClient mockWebChromeClient;
  private DownloadListener mockDownloadListener;
  private WebViewBuilder mockWebViewBuilder;
  private WebView mockWebView;
  private FlutterWebView testFlutterWebView;

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

    testFlutterWebView =
        new FlutterWebView(
            mock(Context.class),
            mockWebViewBuilder,
            mock(MethodChannel.class),
            createParameterMap(true));

    clearInvocations(mockWebViewBuilder);
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

  @Test
  public void loadUrl() {
    testFlutterWebView.loadUrl(
        mockWebView, "www.google.com", Collections.singletonMap("apple", "ewf"));
    verify(mockWebView).loadUrl("www.google.com", Collections.singletonMap("apple", "ewf"));
  }

  @Test
  public void canGoBack() {
    when(mockWebView.canGoBack()).thenReturn(true);
    assertTrue(testFlutterWebView.canGoBack(mockWebView));
  }

  @Test
  public void canGoForward() {
    when(mockWebView.canGoForward()).thenReturn(false);
    assertFalse(testFlutterWebView.canGoForward(mockWebView));
  }

  @Test
  public void goBack() {
    when(mockWebView.canGoBack()).thenReturn(true);

    testFlutterWebView.goBack(mockWebView);
    verify(mockWebView).goBack();
  }

  @Test
  public void goForward() {
    when(mockWebView.canGoForward()).thenReturn(true);

    testFlutterWebView.goForward(mockWebView);
    verify(mockWebView).goForward();
  }

  @Test
  public void reload() {
    testFlutterWebView.reload(mockWebView);
    verify(mockWebView).reload();
  }

  @Test
  public void currentUrl() {
    when(mockWebView.getUrl()).thenReturn("www.google.com");
    assertEquals(testFlutterWebView.currentUrl(mockWebView), "www.google.com");
  }

  @Test
  public void evaluateJavaScript() {
    final String[] successValue = new String[1];
    testFlutterWebView.evaluateJavaScript(
        mockWebView,
        "2 + 2",
        new MethodChannel.Result() {
          @Override
          public void success(@Nullable Object o) {
            successValue[0] = (String) o;
          }

          @Override
          public void error(String s, @Nullable String s1, @Nullable Object o) {}

          @Override
          public void notImplemented() {}
        });

    @SuppressWarnings("unchecked")
    final ArgumentCaptor<ValueCallback<String>> callbackCaptor =
        ArgumentCaptor.forClass(ValueCallback.class);
    verify(mockWebView).evaluateJavascript(eq("2 + 2"), callbackCaptor.capture());

    callbackCaptor.getValue().onReceiveValue("da result");
    assertEquals(successValue[0], "da result");
  }

  @Test
  public void clearCache() {
    testFlutterWebView.clearCache(mockWebView);
    verify(mockWebView).clearCache(true);
  }

  @Test
  public void getTitle() {
    when(mockWebView.getTitle()).thenReturn("My Title");
    assertEquals(testFlutterWebView.getTitle(mockWebView), "My Title");
  }

  @Test
  public void scrollTo() {
    testFlutterWebView.scrollTo(mockWebView, 12, 16);
    verify(mockWebView).scrollTo(12, 16);
  }

  @Test
  public void scrollBy() {
    testFlutterWebView.scrollBy(mockWebView, 234, 34);
    verify(mockWebView).scrollBy(234, 34);
  }

  @Test
  public void getScrollX() {
    when(mockWebView.getScrollX()).thenReturn(23);
    assertEquals(testFlutterWebView.getScrollX(mockWebView), 23);
  }

  @Test
  public void getScrollY() {
    when(mockWebView.getScrollY()).thenReturn(44);
    assertEquals(testFlutterWebView.getScrollY(mockWebView), 44);
  }

  private Map<String, Object> createParameterMap(boolean usesHybridComposition) {
    Map<String, Object> params = new HashMap<>();
    params.put("usesHybridComposition", usesHybridComposition);

    return params;
  }
}
