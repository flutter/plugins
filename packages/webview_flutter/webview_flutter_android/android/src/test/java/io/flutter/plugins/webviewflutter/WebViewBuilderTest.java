// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import io.flutter.plugins.webviewflutter.WebViewBuilder.WebViewFactory;
import java.io.IOException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.MockedStatic.Verification;

public class WebViewBuilderTest {
  private Context mockContext;
  private View mockContainerView;
  private WebView mockWebView;
  private MockedStatic<WebViewFactory> mockedStaticWebViewFactory;

  @Before
  public void before() {
    mockContext = mock(Context.class);
    mockContainerView = mock(View.class);
    mockWebView = mock(WebView.class);
    mockedStaticWebViewFactory = mockStatic(WebViewFactory.class);

    mockedStaticWebViewFactory
        .when(
            new Verification() {
              @Override
              public void apply() {
                WebViewFactory.create(mockContext, false, mockContainerView);
              }
            })
        .thenReturn(mockWebView);
  }

  @After
  public void after() {
    mockedStaticWebViewFactory.close();
  }

  @Test
  public void ctor_test() {
    WebViewBuilder builder = new WebViewBuilder(mockContext, mockContainerView);

    assertNotNull(builder);
  }

  @Test
  public void build_should_set_values() throws IOException {
    WebSettings mockWebSettings = mock(WebSettings.class);
    WebChromeClient mockWebChromeClient = mock(WebChromeClient.class);
    DownloadListener mockDownloadListener = mock(DownloadListener.class);

    when(mockWebView.getSettings()).thenReturn(mockWebSettings);

    WebViewBuilder builder =
        new WebViewBuilder(mockContext, mockContainerView)
            .setDomStorageEnabled(true)
            .setJavaScriptCanOpenWindowsAutomatically(true)
            .setSupportMultipleWindows(true)
            .setWebChromeClient(mockWebChromeClient)
            .setDownloadListener(mockDownloadListener);

    WebView webView = builder.build();

    assertNotNull(webView);
    verify(mockWebSettings).setDomStorageEnabled(true);
    verify(mockWebSettings).setJavaScriptCanOpenWindowsAutomatically(true);
    verify(mockWebSettings).setSupportMultipleWindows(true);
    verify(mockWebView).setWebChromeClient(mockWebChromeClient);
    verify(mockWebView).setDownloadListener(mockDownloadListener);
  }

  @Test
  public void build_should_use_default_values() throws IOException {
    WebSettings mockWebSettings = mock(WebSettings.class);
    WebChromeClient mockWebChromeClient = mock(WebChromeClient.class);

    when(mockWebView.getSettings()).thenReturn(mockWebSettings);

    WebViewBuilder builder = new WebViewBuilder(mockContext, mockContainerView);

    WebView webView = builder.build();

    assertNotNull(webView);
    verify(mockWebSettings).setDomStorageEnabled(false);
    verify(mockWebSettings).setJavaScriptCanOpenWindowsAutomatically(false);
    verify(mockWebSettings).setSupportMultipleWindows(false);
    verify(mockWebView).setWebChromeClient(null);
    verify(mockWebView).setDownloadListener(null);
  }
}
