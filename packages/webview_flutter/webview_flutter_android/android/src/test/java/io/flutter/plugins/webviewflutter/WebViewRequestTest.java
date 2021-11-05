// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;

import java.util.HashMap;
import java.util.Map;
import org.junit.Test;

public class WebViewRequestTest {

  @Test
  public void webViewLoadMethod_serialize_shouldReturnValue() {
    assertEquals("get", WebViewLoadMethod.GET.serialize());
    assertEquals("post", WebViewLoadMethod.POST.serialize());
  }

  @Test
  public void webViewLoadMethod_deserialize_shouldReturnEnumValue() {
    assertEquals(WebViewLoadMethod.GET, WebViewLoadMethod.deserialize("get"));
    assertEquals(WebViewLoadMethod.POST, WebViewLoadMethod.deserialize("post"));
  }

  @Test(expected = IllegalArgumentException.class)
  public void webViewLoadMethod_deserialize_shouldThrowIllegalArgumentExceptionForUnknownValue() {
    WebViewLoadMethod.deserialize("fakeMethod");
  }

  @Test
  public void webViewRequest_shouldConstructWithGivenParams() {
    Map<String, String> headers =
        new HashMap<String, String>() {
          {
            put("3", "3");
          }
        };
    byte[] body = {0x04};
    WebViewRequest req = new WebViewRequest("1", WebViewLoadMethod.POST, headers, body);

    assertEquals(req.getUri(), "1");
    assertEquals(req.getMethod(), WebViewLoadMethod.POST);
    assertEquals(req.getHeaders(), headers);
    assertEquals(req.getBody(), body);
  }

  @Test
  public void webViewRequest_shouldConstructFromMap() {
    final Map<String, String> headers =
        new HashMap<String, String>() {
          {
            put("3", "3");
          }
        };
    final byte[] body = {0x04};
    WebViewRequest req =
        WebViewRequest.fromMap(
            new HashMap<String, Object>() {
              {
                put("url", "1");
                put("method", "post");
                put("headers", headers);
                put("body", body);
              }
            });

    assertEquals(req.getUri(), "1");
    assertEquals(req.getMethod(), WebViewLoadMethod.POST);
    assertEquals(req.getHeaders(), headers);
    assertEquals(req.getBody(), body);
  }
}
