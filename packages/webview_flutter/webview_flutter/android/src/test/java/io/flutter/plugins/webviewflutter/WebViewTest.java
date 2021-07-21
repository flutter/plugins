// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.isA;
import static org.mockito.Mockito.doNothing;

import android.os.Handler;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.internal.matchers.Null;

public class WebViewTest {
  private static final String POST_URL = "postUrl";
  private static final String URL = "www.example.com";
  byte[] postData;

  @Mock WebView mockWebView;
  @Mock MethodChannel mockChannel;
  @Mock Handler mockHandler;
  @Mock MethodChannel.Result mockResult;

  FlutterWebView flutterWebView;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    postData = new byte[5];
  }

  @Test
  public void testPostUrl_should_call_webView_postUrl_with_correct_url() {
    MethodCall call = buildMethodCall(POST_URL, URL, postData);
    flutterWebView = new FlutterWebView(mockWebView, mockChannel, mockHandler);

    ArgumentCaptor<String> valueCapture = ArgumentCaptor.forClass(String.class);

    doNothing().when(mockWebView).postUrl(valueCapture.capture(), isA(byte[].class));

    flutterWebView.postUrl(call, mockResult);

    assertEquals(URL, valueCapture.getValue());
  }

  @Test
  public void testPostUrl_should_call_webView_postUrl_with_correct_http_body() {
    MethodCall call = buildMethodCall(POST_URL, URL, postData);
    flutterWebView = new FlutterWebView(mockWebView, mockChannel, mockHandler);

    ArgumentCaptor<byte[]> valueCapture = ArgumentCaptor.forClass(byte[].class);

    doNothing().when(mockWebView).postUrl(isA(String.class), valueCapture.capture());

    flutterWebView.postUrl(call, mockResult);

    assertEquals(postData, valueCapture.getValue());
  }

  @Test
  public void testPostUrl_should_call_result_success_with_null() {
    MethodCall call = buildMethodCall(POST_URL, URL, postData);
    flutterWebView = new FlutterWebView(mockWebView, mockChannel, mockHandler);

    ArgumentCaptor<Null> valueCapture = ArgumentCaptor.forClass(Null.class);

    doNothing().when(mockResult).success(valueCapture.capture());

    flutterWebView.postUrl(call, mockResult);

    assertEquals(null, valueCapture.getValue());
  }

  @Test
  public void errorCodes() {
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_AUTHENTICATION),
        "authentication");
    assertEquals(FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_BAD_URL), "badUrl");
    assertEquals(FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_CONNECT), "connect");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_FAILED_SSL_HANDSHAKE),
        "failedSslHandshake");
    assertEquals(FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_FILE), "file");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_FILE_NOT_FOUND), "fileNotFound");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_HOST_LOOKUP), "hostLookup");
    assertEquals(FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_IO), "io");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_PROXY_AUTHENTICATION),
        "proxyAuthentication");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_REDIRECT_LOOP), "redirectLoop");
    assertEquals(FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_TIMEOUT), "timeout");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_TOO_MANY_REQUESTS),
        "tooManyRequests");
    assertEquals(FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_UNKNOWN), "unknown");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_UNSAFE_RESOURCE),
        "unsafeResource");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_UNSUPPORTED_AUTH_SCHEME),
        "unsupportedAuthScheme");
    assertEquals(
        FlutterWebViewClient.errorCodeToString(WebViewClient.ERROR_UNSUPPORTED_SCHEME),
        "unsupportedScheme");
  }

  private MethodCall buildMethodCall(String method, final String url, final byte[] postData) {
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("url", url);
    arguments.put("postData", postData);

    return new MethodCall(method, arguments);
  }
}
