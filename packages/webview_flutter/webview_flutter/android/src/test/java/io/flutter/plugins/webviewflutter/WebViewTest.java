// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;

import android.webkit.WebViewClient;
import org.junit.Test;

public class WebViewTest {
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
}
