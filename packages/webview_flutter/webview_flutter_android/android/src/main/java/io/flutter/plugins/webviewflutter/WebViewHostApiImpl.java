// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.content.Context;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;

class WebViewHostApiImpl implements GeneratedAndroidWebView.WebViewHostApi {
  private final InstanceManager instanceManager;
  private final WebViewProxy webViewProxy;
  private final Context context;

  static class WebViewProxy {
    WebView createWebView(Context context) {
      return new WebViewPlatformView(context);
    }

    WebView createInputAwareWebView(Context context) {
      return new InputAwareWebViewPlatformView(context, null);
    }

    void setWebContentsDebuggingEnabled(boolean enabled) {
      WebView.setWebContentsDebuggingEnabled(enabled);
    }
  }

  private static class WebViewPlatformView extends WebView implements PlatformView {
    public WebViewPlatformView(Context context) {
      super(context);
    }

    @Override
    public View getView() {
      return this;
    }

    @Override
    public void dispose() {
      destroy();
    }
  }

  private static class InputAwareWebViewPlatformView extends InputAwareWebView
      implements PlatformView {
    InputAwareWebViewPlatformView(Context context, View containerView) {
      super(context, containerView);
    }

    @Override
    public View getView() {
      return this;
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
      setContainerView(flutterView);
    }

    @Override
    public void onFlutterViewDetached() {
      setContainerView(null);
    }

    @Override
    public void dispose() {
      dispose();
      destroy();
    }

    @Override
    public void onInputConnectionLocked() {
      lockInputConnection();
    }

    @Override
    public void onInputConnectionUnlocked() {
      unlockInputConnection();
    }
  }

  WebViewHostApiImpl(InstanceManager instanceManager, WebViewProxy webViewProxy, Context context) {
    this.instanceManager = instanceManager;
    this.webViewProxy = webViewProxy;
    this.context = context;
  }

  @Override
  public void create(Long instanceId, Boolean useHybridComposition) {
    final WebView webView =
        useHybridComposition
            ? webViewProxy.createWebView(context)
            : webViewProxy.createInputAwareWebView(context);
    instanceManager.addInstance(webView, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    instanceManager.removeInstance(instanceId);
  }

  @Override
  public void loadUrl(Long instanceId, String url, Map<String, String> headers) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.loadUrl(url, headers);
  }

  @Override
  public String getUrl(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    return webView.getUrl();
  }

  @Override
  public Boolean canGoBack(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    return webView.canGoBack();
  }

  @Override
  public Boolean canGoForward(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    return webView.canGoForward();
  }

  @Override
  public void goBack(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.goBack();
  }

  @Override
  public void goForward(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.goForward();
  }

  @Override
  public void reload(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.reload();
  }

  @Override
  public void clearCache(Long instanceId, Boolean includeDiskFiles) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.clearCache(includeDiskFiles);
  }

  @Override
  public void evaluateJavascript(
      Long instanceId, String javascriptString, GeneratedAndroidWebView.Result<String> result) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.evaluateJavascript(javascriptString, result::success);
  }

  @Override
  public String getTitle(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    return webView.getTitle();
  }

  @Override
  public void scrollTo(Long instanceId, Long x, Long y) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.scrollTo(x.intValue(), y.intValue());
  }

  @Override
  public void scrollBy(Long instanceId, Long x, Long y) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.scrollBy(x.intValue(), y.intValue());
  }

  @Override
  public Long getScrollX(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    return (long) webView.getScrollX();
  }

  @Override
  public Long getScrollY(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    return (long) webView.getScrollY();
  }

  @Override
  public void setWebContentsDebuggingEnabled(Boolean enabled) {
    webViewProxy.setWebContentsDebuggingEnabled(enabled);
  }

  @Override
  public void setWebViewClient(Long instanceId, Long webViewClientInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.setWebViewClient((WebViewClient) instanceManager.getInstance(webViewClientInstanceId));
  }

  @Override
  public void addJavaScriptChannel(Long instanceId, Long javaScriptChannelInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    final JavaScriptChannel javaScriptChannel =
        (JavaScriptChannel) instanceManager.getInstance(javaScriptChannelInstanceId);
    webView.addJavascriptInterface(javaScriptChannel, javaScriptChannel.javaScriptChannelName);
  }

  @Override
  public void removeJavaScriptChannel(Long instanceId, Long javaScriptChannelInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    final JavaScriptChannel javaScriptChannel =
        (JavaScriptChannel) instanceManager.getInstance(javaScriptChannelInstanceId);
    webView.removeJavascriptInterface(javaScriptChannel.javaScriptChannelName);
  }

  @Override
  public void setDownloadListener(Long instanceId, Long listenerInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.setDownloadListener((DownloadListener) instanceManager.getInstance(listenerInstanceId));
  }

  @Override
  public void setWebChromeClient(Long instanceId, Long clientInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.setWebChromeClient((WebChromeClient) instanceManager.getInstance(instanceId));
  }
}
