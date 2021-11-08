// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.verify;

import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugins.webviewflutter.WebChromeClientHostApiImpl.WebChromeClientCreator;
import io.flutter.plugins.webviewflutter.WebChromeClientHostApiImpl.WebChromeClientImpl;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebChromeClientTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public WebChromeClientFlutterApiImpl mockFlutterApi;

  @Mock public WebView mockWebView;

  @Mock public WebViewClient mockWebViewClient;

  InstanceManager instanceManager;
  WebChromeClientHostApiImpl hostApiImpl;
  WebChromeClientImpl webChromeClient;

  @Before
  public void setUp() {
    instanceManager = new InstanceManager();
    instanceManager.addInstance(mockWebView, 0L);
    instanceManager.addInstance(mockWebViewClient, 1L);

    final WebChromeClientCreator webChromeClientCreator =
        new WebChromeClientCreator() {
          @Override
          public WebChromeClientImpl createWebChromeClient(
              WebChromeClientFlutterApiImpl flutterApi, WebViewClient webViewClient) {
            webChromeClient = super.createWebChromeClient(flutterApi, webViewClient);
            return webChromeClient;
          }
        };

    hostApiImpl =
        new WebChromeClientHostApiImpl(instanceManager, webChromeClientCreator, mockFlutterApi);
    hostApiImpl.create(2L, 1L);
  }

  @Test
  public void onProgressChanged() {
    webChromeClient.onProgressChanged(mockWebView, 23);
    verify(mockFlutterApi).onProgressChanged(eq(webChromeClient), eq(mockWebView), eq(23L), any());

    reset(mockFlutterApi);
    webChromeClient.release();
    webChromeClient.onProgressChanged(mockWebView, 11);
    verify(mockFlutterApi, never()).onProgressChanged((WebChromeClient) any(), any(), any(), any());
  }
}
