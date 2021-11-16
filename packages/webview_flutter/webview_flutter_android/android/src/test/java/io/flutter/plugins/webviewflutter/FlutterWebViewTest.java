// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;

public class FlutterWebViewTest {
  private WebChromeClient mockWebChromeClient;
  private DownloadListener mockDownloadListener;
  private WebViewBuilder mockWebViewBuilder;
  private WebView mockWebView;
  private MethodChannel.Result mockResult;
  private Context mockContext;
  private MethodChannel mockMethodChannel;

  @Before
  public void before() {

    mockWebChromeClient = mock(WebChromeClient.class);
    mockWebViewBuilder = mock(WebViewBuilder.class);
    mockWebView = mock(WebView.class);
    mockDownloadListener = mock(DownloadListener.class);
    mockResult = mock(MethodChannel.Result.class);
    mockContext = mock(Context.class);
    mockMethodChannel = mock(MethodChannel.class);

    when(mockWebViewBuilder.setDomStorageEnabled(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setJavaScriptCanOpenWindowsAutomatically(anyBoolean()))
        .thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setSupportMultipleWindows(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setUsesHybridComposition(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setZoomControlsEnabled(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setWebChromeClient(any(WebChromeClient.class)))
        .thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setDownloadListener(any(DownloadListener.class)))
        .thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.build()).thenReturn(mockWebView);
  }

  @Test
  public void createWebView_shouldCreateWebViewWithDefaultConfiguration() {
    FlutterWebView.createWebView(
        mockWebViewBuilder, createParameterMap(false), mockWebChromeClient, mockDownloadListener);

    verify(mockWebViewBuilder, times(1)).setDomStorageEnabled(true);
    verify(mockWebViewBuilder, times(1)).setJavaScriptCanOpenWindowsAutomatically(true);
    verify(mockWebViewBuilder, times(1)).setSupportMultipleWindows(true);
    verify(mockWebViewBuilder, times(1)).setUsesHybridComposition(false);
    verify(mockWebViewBuilder, times(1)).setWebChromeClient(mockWebChromeClient);
    verify(mockWebViewBuilder, times(1)).setZoomControlsEnabled(true);
  }

  @Test(expected = UnsupportedOperationException.class)
  public void evaluateJavaScript_shouldThrowForNullString() {
    try (MockedStatic<FlutterWebView> mockedFlutterWebView = mockStatic(FlutterWebView.class)) {
      // Setup
      mockedFlutterWebView
          .when(
              new MockedStatic.Verification() {
                @Override
                public void apply() throws Throwable {
                  FlutterWebView.createWebView(
                      (WebViewBuilder) any(),
                      (Map<String, Object>) any(),
                      (WebChromeClient) any(),
                      (DownloadListener) any());
                }
              })
          .thenReturn(mockWebView);
      FlutterWebView flutterWebView =
          new FlutterWebView(mockContext, mockMethodChannel, new HashMap<String, Object>(), null);

      // Run
      flutterWebView.onMethodCall(new MethodCall("runJavascript", null), mockResult);
    }
  }

  @Test
  public void evaluateJavaScript_shouldReturnValueOnSuccessForReturnValue() {
    try (MockedStatic<FlutterWebView> mockedFlutterWebView = mockStatic(FlutterWebView.class)) {
      // Setup
      mockedFlutterWebView
          .when(
              () ->
                  FlutterWebView.createWebView(
                      (WebViewBuilder) any(),
                      (Map<String, Object>) any(),
                      (WebChromeClient) any(),
                      (DownloadListener) any()))
          .thenReturn(mockWebView);
      doAnswer(
              invocation -> {
                android.webkit.ValueCallback<String> callback = invocation.getArgument(1);
                callback.onReceiveValue("Test JavaScript Result");
                return null;
              })
          .when(mockWebView)
          .evaluateJavascript(eq("Test JavaScript String"), any());
      FlutterWebView flutterWebView =
          new FlutterWebView(mockContext, mockMethodChannel, new HashMap<String, Object>(), null);

      // Run
      flutterWebView.onMethodCall(
          new MethodCall("runJavascriptReturningResult", "Test JavaScript String"), mockResult);

      // Verify
      verify(mockResult, times(1)).success("Test JavaScript Result");
    }
  }

  @Test
  public void evaluateJavaScript_shouldReturnNilOnSuccessForNoReturnValue() {
    try (MockedStatic<FlutterWebView> mockedFlutterWebView = mockStatic(FlutterWebView.class)) {
      // Setup
      mockedFlutterWebView
          .when(
              () ->
                  FlutterWebView.createWebView(
                      (WebViewBuilder) any(),
                      (Map<String, Object>) any(),
                      (WebChromeClient) any(),
                      (DownloadListener) any()))
          .thenReturn(mockWebView);
      doAnswer(
              invocation -> {
                android.webkit.ValueCallback<String> callback = invocation.getArgument(1);
                callback.onReceiveValue("Test JavaScript Result");
                return null;
              })
          .when(mockWebView)
          .evaluateJavascript(eq("Test JavaScript String"), any());
      FlutterWebView flutterWebView =
          new FlutterWebView(mockContext, mockMethodChannel, new HashMap<String, Object>(), null);

      // Run
      flutterWebView.onMethodCall(
          new MethodCall("runJavascript", "Test JavaScript String"), mockResult);

      // Verify
      verify(mockResult, times(1)).success(isNull());
    }
  }

  private Map<String, Object> createParameterMap(boolean usesHybridComposition) {
    Map<String, Object> params = new HashMap<>();
    params.put("usesHybridComposition", usesHybridComposition);

    return params;
  }
}
