// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebChromeClientFlutterApi;
import io.flutter.plugins.webviewflutter.WebChromeClientHostApiImpl.WebChromeClientCreator;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class WebChromeClientTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public WebChromeClientFlutterApi mockFlutterApi;

  @Mock public WebView mockWebView;

  @Mock public WebViewClient mockWebViewClient;

  InstanceManager testInstanceManager;
  WebChromeClientHostApiImpl testHostApiImpl;
  WebChromeClient testWebChromeClient;

  @Before
  public void setUp() {
    testInstanceManager = new InstanceManager();
    testInstanceManager.addInstance(mockWebView, 0L);
    testInstanceManager.addInstance(mockWebViewClient, 1L);

    final WebChromeClientCreator webChromeClientCreator =
        new WebChromeClientCreator() {
          @Override
          WebChromeClient createWebChromeClient(
              Long instanceId,
              InstanceManager instanceManager,
              WebViewClient webViewClient,
              WebChromeClientFlutterApi webChromeClientFlutterApi) {
            testWebChromeClient =
                super.createWebChromeClient(
                    instanceId, instanceManager, webViewClient, webChromeClientFlutterApi);
            return testWebChromeClient;
          }
        };

    testHostApiImpl =
        new WebChromeClientHostApiImpl(testInstanceManager, webChromeClientCreator, mockFlutterApi);
    testHostApiImpl.create(2L, 1L);
  }

  @Test
  public void onProgressChanged() {
    testWebChromeClient.onProgressChanged(mockWebView, 23);
    verify(mockFlutterApi).onProgressChanged(eq(2L), eq(0L), eq(23L), any());
  }
}
