// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.webkit.DownloadListener;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebViewTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public WebView mockWebView;

  @Mock WebViewHostApiImpl.WebViewProxy mockWebViewProxy;

  @Mock Context mockContext;

  InstanceManager testInstanceManager;
  WebViewHostApiImpl testHostApiImpl;

  @Before
  public void setUp() {
    testInstanceManager = new InstanceManager();
    when(mockWebViewProxy.createWebView(mockContext)).thenReturn(mockWebView);
    testHostApiImpl = new WebViewHostApiImpl(testInstanceManager, mockWebViewProxy, mockContext);
    testHostApiImpl.create(0L, true);
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

  @Test
  public void loadUrl() {
    testHostApiImpl.loadUrl(0L, "https://www.google.com", new HashMap<>());
    verify(mockWebView).loadUrl("https://www.google.com", new HashMap<>());
  }

  @Test
  public void getUrl() {
    when(mockWebView.getUrl()).thenReturn("https://www.google.com");
    assertEquals(testHostApiImpl.getUrl(0L), "https://www.google.com");
  }

  @Test
  public void canGoBack() {
    when(mockWebView.canGoBack()).thenReturn(true);
    assertEquals(testHostApiImpl.canGoBack(0L), true);
  }

  @Test
  public void canGoForward() {
    when(mockWebView.canGoForward()).thenReturn(false);
    assertEquals(testHostApiImpl.canGoForward(0L), false);
  }

  @Test
  public void goBack() {
    testHostApiImpl.goBack(0L);
    verify(mockWebView).goBack();
  }

  @Test
  public void goForward() {
    testHostApiImpl.goForward(0L);
    verify(mockWebView).goForward();
  }

  @Test
  public void reload() {
    testHostApiImpl.reload(0L);
    verify(mockWebView).reload();
  }

  @Test
  public void clearCache() {
    testHostApiImpl.clearCache(0L, false);
    verify(mockWebView).clearCache(false);
  }

  @Test
  public void evaluateJavaScript() {
    final String[] successValue = new String[1];
    testHostApiImpl.evaluateJavascript(
        0L,
        "2 + 2",
        new GeneratedAndroidWebView.Result<String>() {
          @Override
          public void success(String result) {
            successValue[0] = result;
          }

          @Override
          public void error(Throwable error) {}
        });

    @SuppressWarnings("unchecked")
    final ArgumentCaptor<ValueCallback<String>> callbackCaptor =
        ArgumentCaptor.forClass(ValueCallback.class);
    verify(mockWebView).evaluateJavascript(eq("2 + 2"), callbackCaptor.capture());

    callbackCaptor.getValue().onReceiveValue("da result");
    assertEquals(successValue[0], "da result");
  }

  @Test
  public void getTitle() {
    when(mockWebView.getTitle()).thenReturn("My title");
    assertEquals(testHostApiImpl.getTitle(0L), "My title");
  }

  @Test
  public void scrollTo() {
    testHostApiImpl.scrollTo(0L, 12L, 13L);
    verify(mockWebView).scrollTo(12, 13);
  }

  @Test
  public void scrollBy() {
    testHostApiImpl.scrollBy(0L, 15L, 23L);
    verify(mockWebView).scrollBy(15, 23);
  }

  @Test
  public void getScrollX() {
    when(mockWebView.getScrollX()).thenReturn(55);
    assertEquals((long) testHostApiImpl.getScrollX(0L), 55);
  }

  @Test
  public void getScrollY() {
    when(mockWebView.getScrollY()).thenReturn(23);
    assertEquals((long) testHostApiImpl.getScrollY(0L), 23);
  }

  @Test
  public void setWebViewClient() {
    final WebViewClient mockWebViewClient = mock(WebViewClient.class);
    testInstanceManager.addInstance(mockWebViewClient, 1L);

    testHostApiImpl.setWebViewClient(0L, 1L);
    verify(mockWebView).setWebViewClient(mockWebViewClient);
  }

  @Test
  public void addJavaScriptChannel() {
    final JavaScriptChannel javaScriptChannel = new JavaScriptChannel(null, "aName", null);
    testInstanceManager.addInstance(javaScriptChannel, 1L);

    testHostApiImpl.addJavaScriptChannel(0L, 1L);
    verify(mockWebView).addJavascriptInterface(javaScriptChannel, "aName");
  }

  @Test
  public void removeJavaScriptChannel() {
    final JavaScriptChannel javaScriptChannel = new JavaScriptChannel(null, "aName", null);
    testInstanceManager.addInstance(javaScriptChannel, 1L);

    testHostApiImpl.removeJavaScriptChannel(0L, 1L);
    verify(mockWebView).removeJavascriptInterface("aName");
  }

  @Test
  public void setDownloadListener() {
    final DownloadListener mockDownloadListener = mock(DownloadListener.class);
    testInstanceManager.addInstance(mockDownloadListener, 1L);

    testHostApiImpl.setDownloadListener(0L, 1L);
    verify(mockWebView).setDownloadListener(mockDownloadListener);
  }
}
