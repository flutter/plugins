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

import android.os.Build;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.webkit.WebViewClientCompat;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.webviewflutter.utils.TestUtils;
import java.util.HashMap;
import java.util.Map;
import org.junit.Assert;
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
  public void notifyDownload_shouldNotifyOnNavigationRequestWhenNavigationDelegateIsSet() {
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
  public void notifyDownload_shouldNotNotifyOnNavigationRequestWhenNavigationDelegateIsNotSet() {
    final String url = "testurl.com";

    FlutterWebViewClient client = new FlutterWebViewClient(mockMethodChannel);
    client.createWebViewClient(false);

    client.notifyDownload(mockWebView, url);
    verifyNoInteractions(mockMethodChannel);
  }

  @Test
  public void WebViewClient_doUpdateVisitedHistory_shouldCallOnUrlChangedEvent() {
    // Setup
    FlutterWebViewClient fltClient = new FlutterWebViewClient(mockMethodChannel);
    WebViewClient client =
        fltClient.createWebViewClient(
            false // Force creation of internal WebViewClient.
            );
    WebView mockView = mock(WebView.class);
    Map<String, Object> methodChannelData = new HashMap<>();
    methodChannelData.put("url", "https://flutter.dev/");

    //Run
    client.doUpdateVisitedHistory(mockView, "https://flutter.dev/", false);

    // Verify
    Assert.assertFalse(client instanceof WebViewClientCompat);
    verify(mockMethodChannel).invokeMethod(eq("onUrlChanged"), eq(methodChannelData));
  }

  @Test
  public void WebViewClientCompat_doUpdateVisitedHistory_shouldCallOnUrlChangedEvent() {
    // Setup
    FlutterWebViewClient fltClient = new FlutterWebViewClient(mockMethodChannel);
    // Force creation of internal WebViewClientCompat (< Android N).
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.M);
    WebViewClient client = fltClient.createWebViewClient(true);

    WebView mockView = mock(WebView.class);
    Map<String, Object> methodChannelData = new HashMap<>();
    methodChannelData.put("url", "https://flutter.dev/");

    //Run
    client.doUpdateVisitedHistory(mockView, "https://flutter.dev/", false);

    // Verify
    Assert.assertTrue(client instanceof WebViewClientCompat);
    verify(mockMethodChannel).invokeMethod(eq("onUrlChanged"), eq(methodChannelData));
  }
}
