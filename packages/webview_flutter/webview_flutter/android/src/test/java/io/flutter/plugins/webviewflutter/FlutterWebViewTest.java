// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.isA;
import static org.mockito.Mockito.doAnswer;
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
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

public class FlutterWebViewTest {
  private static final String LOAD_REQUEST = "loadRequest";
  private static final String URL = "www.example.com";
  private byte[] postData;
  private Map<String, Object> request;
  private Map<String, String> headers;

  private WebChromeClient mockWebChromeClient;
  private WebViewBuilder mockWebViewBuilder;
  private WebView mockWebView;
  private MethodChannel mockChannel;
  private Context mockContext;
  private View mockView;
  private DisplayListenerProxy mockDisplayListenerProxy;
  private MethodChannel.Result mockResult;
  private HttpRequestManager mockHttpRequestManager;

  @Before
  public void before() {
    postData = new byte[5];
    request = new HashMap<>();
    headers = new HashMap<>();

    mockWebView = mock(WebView.class);
    mockWebChromeClient = mock(WebChromeClient.class);
    mockWebViewBuilder = mock(WebViewBuilder.class);
    mockChannel = mock(MethodChannel.class);
    mockContext = mock(Context.class);
    mockView = mock(View.class);
    mockDisplayListenerProxy = mock(DisplayListenerProxy.class);
    mockResult = mock(MethodChannel.Result.class);
    mockHttpRequestManager = mock(HttpRequestManager.class);

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
  public void loadRequest_should_call_webView_postUrl_with_correct_url() {
    FlutterWebView flutterWebView = initFlutterWebView();

    request.put("url", URL);
    request.put("method", "post");
    request.put("headers", null);
    request.put("body", postData);

    MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing().when(mockWebView).postUrl(valueCapture.capture(), isA(byte[].class));

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals(URL, valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_call_webView_postUrl_with_correct_http_body() {
    FlutterWebView flutterWebView = initFlutterWebView();

    request.put("url", URL);
    request.put("method", "post");
    request.put("headers", null);
    request.put("body", postData);

    MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    ArgumentCaptor<byte[]> valueCapture = ArgumentCaptor.forClass(byte[].class);

    doNothing().when(mockWebView).postUrl(ArgumentMatchers.any(), valueCapture.capture());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals(postData, valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_call_result_success_with_null() {
    FlutterWebView flutterWebView = initFlutterWebView();

    request.put("url", URL);
    request.put("method", "post");
    request.put("headers", null);
    request.put("body", postData);

    MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    ArgumentCaptor<Null> valueCapture = ArgumentCaptor.forClass(Null.class);

    doNothing().when(mockResult).success(valueCapture.capture());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals(null, valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_return_error_when_arguments_are_null() {
    FlutterWebView flutterWebView = initFlutterWebView();

    MethodCall call = buildMethodCall(LOAD_REQUEST, null);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing().when(mockResult).error(valueCapture.capture(), anyString(), any());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals("missing_args", valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_return_error_when_webview_is_null() {
    FlutterWebView flutterWebView = initFlutterWebView();
    headers.put("Content-Type", "application/json");

    request.put("url", URL);
    request.put("method", "post");
    request.put("headers", headers);
    request.put("body", postData);

    final MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    when(mockWebView.isAttachedToWindow()).thenReturn(false);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing().when(mockResult).error(valueCapture.capture(), anyString(), any());

    doAnswer(
            new Answer<Void>() {
              @Override
              public Void answer(InvocationOnMock invocationOnMock) throws Throwable {
                HttpRequestCallback callback =
                    (HttpRequestCallback) invocationOnMock.getArguments()[1];
                callback.onComplete("");
                return null;
              }
            })
        .when(mockHttpRequestManager)
        .requestAsync(ArgumentMatchers.any(), ArgumentMatchers.any());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals("webview_destroyed", valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_return_error_when_exception_caught() {
    FlutterWebView flutterWebView = initFlutterWebView();
    headers.put("Content-Type", "application/json");

    request.put("url", URL);
    request.put("method", "post");
    request.put("headers", headers);
    request.put("body", postData);

    final MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    when(mockWebView.isAttachedToWindow()).thenReturn(true);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing().when(mockResult).error(valueCapture.capture(), anyString(), any());

    doAnswer(
            new Answer<Void>() {
              @Override
              public Void answer(InvocationOnMock invocationOnMock) throws Throwable {
                HttpRequestCallback callback =
                    (HttpRequestCallback) invocationOnMock.getArguments()[1];
                callback.onError(null);
                return null;
              }
            })
        .when(mockHttpRequestManager)
        .requestAsync(ArgumentMatchers.any(), ArgumentMatchers.any());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals("request_failed", valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_call_webView_loadUrl_with_correct_url() {
    FlutterWebView flutterWebView = initFlutterWebView();

    request.put("url", URL);
    request.put("method", "get");
    request.put("headers", null);

    MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing().when(mockWebView).loadUrl(valueCapture.capture(), ArgumentMatchers.anyMap());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals(URL, valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_call_webView_loadUrl_with_correct_http_headers() {
    FlutterWebView flutterWebView = initFlutterWebView();
    headers.put("Content-Type", "application/json");

    request.put("url", URL);
    request.put("method", "get");
    request.put("headers", headers);

    MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    ArgumentCaptor<Map<String, String>> valueCapture = ArgumentCaptor.forClass(Map.class);

    doNothing().when(mockWebView).loadUrl(anyString(), valueCapture.capture());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals(headers, valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_call_webView_loadDataWithBaseURL_with_correct_url() {
    FlutterWebView flutterWebView = initFlutterWebView();

    headers.put("Content-Type", "application/json");

    request.put("url", URL);
    request.put("method", "post");
    request.put("headers", headers);
    request.put("body", postData);

    MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    when(mockWebView.isAttachedToWindow()).thenReturn(true);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing()
        .when(mockWebView)
        .loadDataWithBaseURL(
            valueCapture.capture(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any());

    doAnswer(
            new Answer<Void>() {
              @Override
              public Void answer(InvocationOnMock invocationOnMock) throws Throwable {
                HttpRequestCallback callback =
                    (HttpRequestCallback) invocationOnMock.getArguments()[1];
                callback.onComplete("");
                return null;
              }
            })
        .when(mockHttpRequestManager)
        .requestAsync(ArgumentMatchers.any(), ArgumentMatchers.any());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals(URL, valueCapture.getValue());
  }

  @Test
  public void loadRequest_should_call_webView_loadDataWithBaseURL_with_correct_http_response() {
    FlutterWebView flutterWebView = initFlutterWebView();

    final String content = "content";

    headers.put("Content-Type", "application/json");

    request.put("url", URL);
    request.put("method", "post");
    request.put("headers", headers);
    request.put("body", postData);

    MethodCall call = buildMethodCall(LOAD_REQUEST, request);

    when(mockWebView.isAttachedToWindow()).thenReturn(true);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing()
        .when(mockWebView)
        .loadDataWithBaseURL(
            ArgumentMatchers.any(),
            valueCapture.capture(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any());

    doAnswer(
            new Answer<Void>() {
              @Override
              public Void answer(InvocationOnMock invocationOnMock) throws Throwable {
                HttpRequestCallback callback =
                    (HttpRequestCallback) invocationOnMock.getArguments()[1];
                callback.onComplete(content);
                return null;
              }
            })
        .when(mockHttpRequestManager)
        .requestAsync(ArgumentMatchers.any(), ArgumentMatchers.any());

    flutterWebView.onMethodCall(call, mockResult);

    assertEquals(content, valueCapture.getValue());
  }

  private Map<String, Object> createParameterMap(boolean usesHybridComposition) {
    Map<String, Object> params = new HashMap<>();
    params.put("usesHybridComposition", usesHybridComposition);

    return params;
  }

  private MethodCall buildMethodCall(final String method, final Map<String, Object> request) {
    if (request == null) {
      return new MethodCall(method, null);
    }
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("request", request);

    return new MethodCall(method, arguments);
  }

  private FlutterWebView initFlutterWebView() {
    try (MockedStatic<FlutterWebView.HttpRequestManagerFactory> mockedHttpRequestManagerFactory =
        mockStatic(FlutterWebView.HttpRequestManagerFactory.class)) {
      mockedHttpRequestManagerFactory
          .when(
              () ->
                  FlutterWebView.HttpRequestManagerFactory.create(
                      ArgumentMatchers.any(), ArgumentMatchers.any()))
          .thenReturn(mockHttpRequestManager);
      try (MockedStatic<FlutterWebView> mockedStaticFlutterWebView =
          mockStatic(FlutterWebView.class)) {

        mockedStaticFlutterWebView
            .when(
                () ->
                    FlutterWebView.createWebView(
                        ArgumentMatchers.any(), ArgumentMatchers.anyMap(), ArgumentMatchers.any()))
            .thenReturn(mockWebView);

        return new FlutterWebView(
            mockContext,
            mockChannel,
            createParameterMap(false),
            mockView,
            mockDisplayListenerProxy);
      }
    }
  }
}
