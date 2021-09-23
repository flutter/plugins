// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.content.Context;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/** Builder used to create {@link android.webkit.WebView} objects. */
public class WebViewBuilder {

  /** Factory used to create a new {@link android.webkit.WebView} instance. */
  static class WebViewFactory {

    /**
     * Creates a new {@link android.webkit.WebView} instance.
     *
     * @param context an Activity Context to access application assets. This value cannot be null.
     * @param usesHybridComposition If {@code false} a {@link InputAwareWebView} instance is
     *     returned.
     * @param containerView must be supplied when the {@code useHybridComposition} parameter is set
     *     to {@code false}. Used to create an InputConnection on the WebView's dedicated input, or
     *     IME, thread (see also {@link InputAwareWebView})
     * @return A new instance of the {@link android.webkit.WebView} object.
     */
    static WebView create(Context context, boolean usesHybridComposition, View containerView) {
      return usesHybridComposition
          ? new WebView(context)
          : new InputAwareWebView(context, containerView);
    }
  }

  private final Context context;
  private final View containerView;

  private boolean enableDomStorage;
  private boolean javaScriptCanOpenWindowsAutomatically;
  private boolean supportMultipleWindows;
  private boolean usesHybridComposition;
  private WebChromeClient webChromeClient;
  private DownloadListener downloadListener;

  /**
   * Constructs a new {@link WebViewBuilder} object with a custom implementation of the {@link
   * WebViewFactory} object.
   *
   * @param context an Activity Context to access application assets. This value cannot be null.
   * @param containerView must be supplied when the {@code useHybridComposition} parameter is set to
   *     {@code false}. Used to create an InputConnection on the WebView's dedicated input, or IME,
   *     thread (see also {@link InputAwareWebView})
   */
  WebViewBuilder(@NonNull final Context context, View containerView) {
    this.context = context;
    this.containerView = containerView;
  }

  /**
   * Sets whether the DOM storage API is enabled. The default value is {@code false}.
   *
   * @param flag {@code true} is {@link android.webkit.WebView} should use the DOM storage API.
   * @return This builder. This value cannot be {@code null}.
   */
  public WebViewBuilder setDomStorageEnabled(boolean flag) {
    this.enableDomStorage = flag;
    return this;
  }

  /**
   * Sets whether JavaScript is allowed to open windows automatically. This applies to the
   * JavaScript function {@code window.open()}. The default value is {@code false}.
   *
   * @param flag {@code true} if JavaScript is allowed to open windows automatically.
   * @return This builder. This value cannot be {@code null}.
   */
  public WebViewBuilder setJavaScriptCanOpenWindowsAutomatically(boolean flag) {
    this.javaScriptCanOpenWindowsAutomatically = flag;
    return this;
  }

  /**
   * Sets whether the {@link WebView} supports multiple windows. If set to {@code true}, {@link
   * WebChromeClient#onCreateWindow} must be implemented by the host application. The default is
   * {@code false}.
   *
   * @param flag {@code true} if multiple windows are supported.
   * @return This builder. This value cannot be {@code null}.
   */
  public WebViewBuilder setSupportMultipleWindows(boolean flag) {
    this.supportMultipleWindows = flag;
    return this;
  }

  /**
   * Sets whether the hybrid composition should be used.
   *
   * <p>If set to {@code true} a standard {@link WebView} is created. If set to {@code false} the
   * {@link WebViewBuilder} will create a {@link InputAwareWebView} to workaround issues using the
   * {@link WebView} on Android versions below N.
   *
   * @param flag {@code true} if uses hybrid composition. The default is {@code false}.
   * @return This builder. This value cannot be {@code null}
   */
  public WebViewBuilder setUsesHybridComposition(boolean flag) {
    this.usesHybridComposition = flag;
    return this;
  }

  /**
   * Sets the chrome handler. This is an implementation of WebChromeClient for use in handling
   * JavaScript dialogs, favicons, titles, and the progress. This will replace the current handler.
   *
   * @param webChromeClient an implementation of WebChromeClient This value may be null.
   * @return This builder. This value cannot be {@code null}.
   */
  public WebViewBuilder setWebChromeClient(@Nullable WebChromeClient webChromeClient) {
    this.webChromeClient = webChromeClient;
    return this;
  }

  /**
   * Registers the interface to be used when content can not be handled by the rendering engine, and
   * should be downloaded instead. This will replace the current handler.
   *
   * @param downloadListener an implementation of DownloadListener This value may be null.
   * @return This builder. This value cannot be {@code null}.
   */
  public WebViewBuilder setDownloadListener(@Nullable DownloadListener downloadListener) {
    this.downloadListener = downloadListener;
    return this;
  }

  /**
   * Build the {@link android.webkit.WebView} using the current settings.
   *
   * @return The {@link android.webkit.WebView} using the current settings.
   */
  public WebView build() {
    WebView webView = WebViewFactory.create(context, usesHybridComposition, containerView);

    WebSettings webSettings = webView.getSettings();
    webSettings.setDomStorageEnabled(enableDomStorage);
    webSettings.setJavaScriptCanOpenWindowsAutomatically(javaScriptCanOpenWindowsAutomatically);
    webSettings.setSupportMultipleWindows(supportMultipleWindows);
    webView.setWebChromeClient(webChromeClient);
    webView.setDownloadListener(downloadListener);
    return webView;
  }
}
