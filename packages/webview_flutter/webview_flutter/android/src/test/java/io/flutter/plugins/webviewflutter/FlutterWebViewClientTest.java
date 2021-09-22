// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

import android.webkit.WebView;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;

public class FlutterWebViewClientTest {

  MethodChannel mockMethodChannel;
  WebView mockWebView;

  @Before
  public void before() {
    mockMethodChannel = mock(MethodChannel.class);
    mockWebView = mock(WebView.class);
  }

  @Test
  public void notify_download_should_notifyOnNavigationRequest_when_navigationDelegate_is_set() {
    final String url = "testurl.com";

    FlutterWebViewClient client = new FlutterWebViewClient(mockMethodChannel);
    client.createWebViewClient(true);

    client.notifyDownload(mockWebView, url);
    ArgumentCaptor<Object> argumentCaptor = ArgumentCaptor.forClass(Object.class);
    verify(mockMethodChannel)
        .invokeMethod(
            eq("navigationRequest"), argumentCaptor.capture(), any(MethodChannel.Result.class));
    HashMap<String, Object> map = (HashMap<String, Object>) argumentCaptor.getValue();
    assertEquals(map.get("url"), url);
    assertEquals(map.get("isForMainFrame"), true);
  }

  @Test
  public void
      notify_download_should_not_notifyOnNavigationRequest_when_navigationDelegate_is_not_set() {
    final String url = "testurl.com";

    FlutterWebViewClient client = new FlutterWebViewClient(mockMethodChannel);
    client.createWebViewClient(false);

    client.notifyDownload(mockWebView, url);
    verifyNoInteractions(mockMethodChannel);
  }
}
