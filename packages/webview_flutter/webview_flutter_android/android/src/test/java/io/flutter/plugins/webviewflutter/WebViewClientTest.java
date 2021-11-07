// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugins.webviewflutter.WebViewClientHostApiImpl.WebViewClientCreator;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebViewClientTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public WebViewClientFlutterApiImpl mockFlutterApi;

  @Mock public WebView mockWebView;

  InstanceManager testInstanceManager;
  WebViewClientHostApiImpl testHostApiImpl;
  WebViewClient testWebViewClient;

  @Before
  public void setUp() {
    testInstanceManager = new InstanceManager();
    testInstanceManager.addInstance(mockWebView, 0L);

    final WebViewClientCreator webViewClientCreator =
        new WebViewClientCreator() {
      @Override
          public WebViewClient createWebViewClient(WebViewClientFlutterApiImpl flutterApi, boolean shouldOverrideUrlLoading) {
            testWebViewClient = super.createWebViewClient(flutterApi, shouldOverrideUrlLoading);
            return testWebViewClient;
          }
        };

    testHostApiImpl =
        new WebViewClientHostApiImpl(testInstanceManager, webViewClientCreator, mockFlutterApi);
    testHostApiImpl.create(1L, true);
  }

  @Test
  public void onPageStarted() {
    testWebViewClient.onPageStarted(mockWebView, "https://www.google.com", null);
    verify(mockFlutterApi).onPageStarted(eq(1L), eq(0L), eq("https://www.google.com"), any());
  }

  @Test
  public void onReceivedError() {
    testWebViewClient.onReceivedError(mockWebView, 32, "description", "https://www.google.com");
    verify(mockFlutterApi)
        .onReceivedError(
            eq(1L), eq(0L), eq(32L), eq("description"), eq("https://www.google.com"), any());
  }

  @Test
  public void urlLoading() {
    testWebViewClient.shouldOverrideUrlLoading(mockWebView, "https://www.google.com");
    verify(mockFlutterApi).urlLoading(eq(1L), eq(0L), eq("https://www.google.com"), any());
  }
}
