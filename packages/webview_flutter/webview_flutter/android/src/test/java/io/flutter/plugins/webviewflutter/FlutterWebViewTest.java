// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.isA;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.mockito.MockedStatic;
import org.mockito.internal.matchers.Null;

public class FlutterWebViewTest {
  private static final String POST_URL = "postUrl";
  private static final String URL = "www.example.com";
  private byte[] postData;

  private WebChromeClient mockWebChromeClient;
  private WebViewBuilder mockWebViewBuilder;
  private WebView mockWebView;
  private MethodChannel mockChannel;
  private Context mockContext;
  private View mockView;
  private DisplayListenerProxy mockDisplayListenerProxy;
  private MethodChannel.Result mockResult;

  @Before
  public void before() {
    postData = new byte[5];

    mockWebView = mock(WebView.class);
    mockWebChromeClient = mock(WebChromeClient.class);
    mockWebViewBuilder = mock(WebViewBuilder.class);
    mockChannel = mock(MethodChannel.class);
    mockContext = mock(Context.class);
    mockView = mock(View.class);
    mockDisplayListenerProxy = mock(DisplayListenerProxy.class);
    mockResult = mock(MethodChannel.Result.class);

    when(mockWebViewBuilder.setDomStorageEnabled(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setJavaScriptCanOpenWindowsAutomatically(anyBoolean()))
        .thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setSupportMultipleWindows(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setUsesHybridComposition(anyBoolean())).thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.setWebChromeClient(any(WebChromeClient.class)))
        .thenReturn(mockWebViewBuilder);
    when(mockWebViewBuilder.build()).thenReturn(mockWebView);
  }

  @Test
  public void createWebView_should_create_webview_with_default_configuration() {
    FlutterWebView.createWebView(
        mockWebViewBuilder, createParameterMap(false), mockWebChromeClient);

    verify(mockWebViewBuilder, times(1)).setDomStorageEnabled(true);
    verify(mockWebViewBuilder, times(1)).setJavaScriptCanOpenWindowsAutomatically(true);
    verify(mockWebViewBuilder, times(1)).setSupportMultipleWindows(true);
    verify(mockWebViewBuilder, times(1)).setUsesHybridComposition(false);
    verify(mockWebViewBuilder, times(1)).setWebChromeClient(mockWebChromeClient);
  }

  @Test
  public void testPostUrl_should_call_webView_postUrl_with_correct_url() {
    FlutterWebView flutterWebView = initFlutterWebView();

    MethodCall call = buildMethodCall(POST_URL, URL, postData);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing().when(mockWebView).postUrl(valueCapture.capture(), isA(byte[].class));

    flutterWebView.postUrl(call, mockResult);

    assertEquals(URL, valueCapture.getValue());
  }

  @Test
  public void testPostUrl_should_call_webView_postUrl_with_correct_http_body() {
    FlutterWebView flutterWebView = initFlutterWebView();

    MethodCall call = buildMethodCall(POST_URL, URL, postData);

    ArgumentCaptor<byte[]> valueCapture = ArgumentCaptor.forClass(byte[].class);

    doNothing().when(mockWebView).postUrl(isA(String.class), valueCapture.capture());

    flutterWebView.postUrl(call, mockResult);

    assertEquals(postData, valueCapture.getValue());
  }

  @Test
  public void testPostUrl_should_call_result_success_with_null() {
    FlutterWebView flutterWebView = initFlutterWebView();

    MethodCall call = buildMethodCall(POST_URL, URL, postData);

    ArgumentCaptor<Null> valueCapture = ArgumentCaptor.forClass(Null.class);

    doNothing().when(mockResult).success(valueCapture.capture());

    flutterWebView.postUrl(call, mockResult);

    assertEquals(null, valueCapture.getValue());
  }

  private Map<String, Object> createParameterMap(boolean usesHybridComposition) {
    Map<String, Object> params = new HashMap<>();
    params.put("usesHybridComposition", usesHybridComposition);

    return params;
  }

  private MethodCall buildMethodCall(String method, final String url, final byte[] postData) {
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("url", url);
    arguments.put("postData", postData);

    return new MethodCall(method, arguments);
  }

  private FlutterWebView initFlutterWebView() {
    try (MockedStatic<FlutterWebView> mockedStaticFlutterWebView =
        mockStatic(FlutterWebView.class)) {

      mockedStaticFlutterWebView
          .when(
              new MockedStatic.Verification() {
                @Override
                public void apply() throws Throwable {
                  FlutterWebView.createWebView(
                      ArgumentMatchers.<WebViewBuilder>any(),
                      ArgumentMatchers.<String, Object>anyMap(),
                      ArgumentMatchers.<WebChromeClient>any());
                }
              })
          .thenReturn(mockWebView);

      return new FlutterWebView(
          mockContext, mockChannel, createParameterMap(false), mockView, mockDisplayListenerProxy);
    }
  }
}
