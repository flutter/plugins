// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import java.util.Collections;
import java.util.Map;

/**
 * Defines the supported HTTP methods for loading a page in the {@link android.webkit.WebView} and
 * the {@link HttpRequestManager}.
 */
enum WebViewLoadMethod {
  GET("get"),

  POST("post");

  private final String value;

  WebViewLoadMethod(String value) {
    this.value = value;
  }

  /** Converts to WebViewLoadMethod to String format. */
  public String serialize() {
    return getValue();
  }

  /** Returns the enum value. */
  public String getValue() {
    return value;
  }

  /** Converts to String to WebViewLoadMethod format. */
  public static WebViewLoadMethod deserialize(String value) {
    for (WebViewLoadMethod webViewLoadMethod : WebViewLoadMethod.values()) {
      if (webViewLoadMethod.value.equals(value)) {
        return webViewLoadMethod;
      }
    }
    throw new IllegalArgumentException("No enum value found for '" + value + "'.");
  }
}

/**
 * Creates a HTTP request object.
 *
 * <p>Defines the parameters that can be used to load a page in the {@link android.webkit.WebView}
 * and the {@link HttpRequestManager}.
 */
public class WebViewRequest {
  private final String url;
  private final WebViewLoadMethod method;
  private final Map<String, String> headers;
  private final byte[] body;

  WebViewRequest(String url, WebViewLoadMethod method, Map<String, String> headers, byte[] body) {
    this.url = url;
    this.method = method;
    this.headers = headers == null ? Collections.emptyMap() : headers;
    this.body = body;
  }

  /**
   * Deserializes the request and the url to WebViewRequest instance.
   *
   * @param requestObject is the {@link io.flutter.plugin.common.MethodCall#arguments} to build
   *     WebViewRequest instance.
   */
  @SuppressWarnings("unchecked")
  static WebViewRequest fromMap(Map<String, Object> requestObject) {
    String url = (String) requestObject.get("url");
    if (url == null) {
      return null;
    }

    Map<String, String> headers = (Map<String, String>) requestObject.get("headers");

    WebViewLoadMethod invokedMethod =
        WebViewLoadMethod.deserialize((String) requestObject.get("method"));

    byte[] httpBody = (byte[]) requestObject.get("body");

    return new WebViewRequest(url, invokedMethod, headers, httpBody);
  }

  /** Returns HTTP method in WebViewLoadMethod format. */
  public WebViewLoadMethod getMethod() {
    return method;
  }

  /** Returns base url. */
  public String getUrl() {
    return url;
  }

  /** Returns HTTP headers. */
  public Map<String, String> getHeaders() {
    return headers;
  }

  /** Returns HTTP body. */
  public byte[] getBody() {
    return body;
  }
}
