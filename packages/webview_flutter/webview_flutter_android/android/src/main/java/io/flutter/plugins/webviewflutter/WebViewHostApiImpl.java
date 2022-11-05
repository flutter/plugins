// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.hardware.display.DisplayManager;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugins.webviewflutter.DownloadListenerHostApiImpl.DownloadListenerImpl;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebViewHostApi;
import io.flutter.plugins.webviewflutter.WebChromeClientHostApiImpl.WebChromeClientImpl;
import io.flutter.plugins.webviewflutter.WebViewClientHostApiImpl.ReleasableWebViewClient;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * Host api implementation for {@link WebView}.
 *
 * <p>Handles creating {@link WebView}s that intercommunicate with a paired Dart object.
 */
public class WebViewHostApiImpl implements WebViewHostApi {
  private final InstanceManager instanceManager;
  private final WebViewProxy webViewProxy;
  // Only used with WebView using virtual displays.
  @Nullable private final View containerView;

  private Context context;

  /** Handles creating and calling static methods for {@link WebView}s. */
  public static class WebViewProxy {
    /**
     * Creates a {@link WebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets
     * @return the created {@link WebViewPlatformView}
     */
    public WebViewPlatformView createWebView(Context context) {
      return new WebViewPlatformView(context);
    }

    /**
     * Creates a {@link InputAwareWebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets
     * @param containerView parent View of the WebView
     * @return the created {@link InputAwareWebViewPlatformView}
     */
    public InputAwareWebViewPlatformView createInputAwareWebView(
        Context context, @Nullable View containerView) {
      return new InputAwareWebViewPlatformView(context, containerView);
    }

    /**
     * Forwards call to {@link WebView#setWebContentsDebuggingEnabled}.
     *
     * @param enabled whether debugging should be enabled
     */
    public void setWebContentsDebuggingEnabled(boolean enabled) {
      WebView.setWebContentsDebuggingEnabled(enabled);
    }
  }

  private static class ReleasableValue<T extends Releasable> {
    @Nullable private T value;

    ReleasableValue() {}

    ReleasableValue(@Nullable T value) {
      this.value = value;
    }

    void set(@Nullable T newValue) {
      release();
      value = newValue;
    }

    @Nullable
    T get() {
      return value;
    }

    void release() {
      if (value != null) {
        value.release();
      }
      value = null;
    }
  }

  /** Implementation of {@link WebView} that can be used as a Flutter {@link PlatformView}s. */
  public static class WebViewPlatformView extends WebView implements PlatformView, Releasable {
    private final ReleasableValue<WebViewClientHostApiImpl.ReleasableWebViewClient>
        currentWebViewClient = new ReleasableValue<>();
    private final ReleasableValue<DownloadListenerImpl> currentDownloadListener =
        new ReleasableValue<>();
    private final ReleasableValue<WebChromeClientImpl> currentWebChromeClient =
        new ReleasableValue<>();
    private final Map<String, ReleasableValue<JavaScriptChannel>> javaScriptInterfaces =
        new HashMap<>();

    /**
     * Creates a {@link WebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets. This value cannot be null.
     */
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

    @Override
    public void setWebViewClient(WebViewClient webViewClient) {
      super.setWebViewClient(webViewClient);
      currentWebViewClient.set((ReleasableWebViewClient) webViewClient);

      final WebChromeClientImpl webChromeClient = currentWebChromeClient.get();
      if (webChromeClient != null) {
        ((WebChromeClientImpl) webChromeClient).setWebViewClient(webViewClient);
      }
    }

    @Override
    public void setDownloadListener(DownloadListener listener) {
      super.setDownloadListener(listener);
      currentDownloadListener.set((DownloadListenerImpl) listener);
    }

    @Override
    public void setWebChromeClient(WebChromeClient client) {
      super.setWebChromeClient(client);
      currentWebChromeClient.set((WebChromeClientImpl) client);
    }

    @SuppressLint("JavascriptInterface")
    @Override
    public void addJavascriptInterface(Object object, String name) {
      super.addJavascriptInterface(object, name);
      if (object instanceof JavaScriptChannel) {
        final ReleasableValue<JavaScriptChannel> javaScriptChannel = javaScriptInterfaces.get(name);
        if (javaScriptChannel != null && javaScriptChannel.get() != object) {
          javaScriptChannel.release();
        }
        javaScriptInterfaces.put(name, new ReleasableValue<>((JavaScriptChannel) object));
      }
    }

    @Override
    public void removeJavascriptInterface(@NonNull String name) {
      super.removeJavascriptInterface(name);
      final ReleasableValue<JavaScriptChannel> javaScriptChannel = javaScriptInterfaces.get(name);
      javaScriptChannel.release();
      javaScriptInterfaces.remove(name);
    }

    @Override
    public void release() {
      currentWebViewClient.release();
      currentDownloadListener.release();
      currentWebChromeClient.release();
      for (ReleasableValue<JavaScriptChannel> channel : javaScriptInterfaces.values()) {
        channel.release();
      }
      javaScriptInterfaces.clear();
    }
  }

  /**
   * Implementation of {@link InputAwareWebView} that can be used as a Flutter {@link
   * PlatformView}s.
   */
  @SuppressLint("ViewConstructor")
  public static class InputAwareWebViewPlatformView extends InputAwareWebView
      implements PlatformView, Releasable {
    private final ReleasableValue<WebViewClientHostApiImpl.ReleasableWebViewClient>
        currentWebViewClient = new ReleasableValue<>();
    private final ReleasableValue<DownloadListenerImpl> currentDownloadListener =
        new ReleasableValue<>();
    private final ReleasableValue<WebChromeClientImpl> currentWebChromeClient =
        new ReleasableValue<>();
    private final Map<String, ReleasableValue<JavaScriptChannel>> javaScriptInterfaces =
        new HashMap<>();

    /**
     * Creates a {@link InputAwareWebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets. This value cannot be null.
     */
    public InputAwareWebViewPlatformView(Context context, View containerView) {
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
      super.dispose();
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

    @Override
    public void setWebViewClient(WebViewClient webViewClient) {
      super.setWebViewClient(webViewClient);
      currentWebViewClient.set((ReleasableWebViewClient) webViewClient);

      final WebChromeClientImpl webChromeClient = currentWebChromeClient.get();
      if (webChromeClient != null) {
        webChromeClient.setWebViewClient(webViewClient);
      }
    }

    @Override
    public void setDownloadListener(DownloadListener listener) {
      super.setDownloadListener(listener);
      currentDownloadListener.set((DownloadListenerImpl) listener);
    }

    @Override
    public void setWebChromeClient(WebChromeClient client) {
      super.setWebChromeClient(client);
      currentWebChromeClient.set((WebChromeClientImpl) client);
    }

    @SuppressLint("JavascriptInterface")
    @Override
    public void addJavascriptInterface(Object object, String name) {
      super.addJavascriptInterface(object, name);
      if (object instanceof JavaScriptChannel) {
        final ReleasableValue<JavaScriptChannel> javaScriptChannel = javaScriptInterfaces.get(name);
        if (javaScriptChannel != null && javaScriptChannel.get() != object) {
          javaScriptChannel.release();
        }
        javaScriptInterfaces.put(name, new ReleasableValue<>((JavaScriptChannel) object));
      }
    }

    @Override
    public void removeJavascriptInterface(@NonNull String name) {
      super.removeJavascriptInterface(name);
      final ReleasableValue<JavaScriptChannel> javaScriptChannel = javaScriptInterfaces.get(name);
      javaScriptChannel.release();
      javaScriptInterfaces.remove(name);
    }

    @Override
    public void release() {
      currentWebViewClient.release();
      currentDownloadListener.release();
      currentWebChromeClient.release();
      for (ReleasableValue<JavaScriptChannel> channel : javaScriptInterfaces.values()) {
        channel.release();
      }
      javaScriptInterfaces.clear();
    }
  }

  /**
   * Creates a host API that handles creating {@link WebView}s and invoking its methods.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   * @param webViewProxy handles creating {@link WebView}s and calling its static methods
   * @param context an Activity Context to access application assets. This value cannot be null.
   * @param containerView parent of the webView
   */
  public WebViewHostApiImpl(
      InstanceManager instanceManager,
      WebViewProxy webViewProxy,
      Context context,
      @Nullable View containerView) {
    this.instanceManager = instanceManager;
    this.webViewProxy = webViewProxy;
    this.context = context;
    this.containerView = containerView;
  }

  /**
   * Sets the context to construct {@link WebView}s.
   *
   * @param context the new context.
   */
  public void setContext(Context context) {
    this.context = context;
  }

  @Override
  public void create(Long instanceId, Boolean useHybridComposition) {
    DisplayListenerProxy displayListenerProxy = new DisplayListenerProxy();
    DisplayManager displayManager =
        (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    displayListenerProxy.onPreWebViewInitialization(displayManager);

    final WebView webView =
        useHybridComposition
            ? webViewProxy.createWebView(context)
            : webViewProxy.createInputAwareWebView(context, containerView);

    displayListenerProxy.onPostWebViewInitialization(displayManager);
    instanceManager.addDartCreatedInstance(webView, instanceId);
  }

  @Override
  public void dispose(Long instanceId) {
    final WebView instance = (WebView) instanceManager.getInstance(instanceId);
    if (instance != null) {
      ((Releasable) instance).release();
      instanceManager.remove(instanceId);
    }
  }

  @Override
  public void loadData(Long instanceId, String data, String mimeType, String encoding) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.loadData(data, mimeType, encoding);
    }
  }

  @Override
  public void loadDataWithBaseUrl(
      Long instanceId,
      String baseUrl,
      String data,
      String mimeType,
      String encoding,
      String historyUrl) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
    }
  }

  @Override
  public void loadUrl(Long instanceId, String url, Map<String, String> headers) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.loadUrl(url, headers);
    }
  }

  @Override
  public void postUrl(Long instanceId, String url, byte[] data) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.postUrl(url, data);
    }
  }

  @Override
  public String getUrl(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      return webView.getUrl();
    }
  }

  @Override
  public Boolean canGoBack(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      return webView.canGoBack();
    }
  }

  @Override
  public Boolean canGoForward(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      return webView.canGoForward();
    }
  }

  @Override
  public void goBack(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.goBack();
    }
  }

  @Override
  public void goForward(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.goForward();
    }
  }

  @Override
  public void reload(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.reload();
    }
  }

  @Override
  public void clearCache(Long instanceId, Boolean includeDiskFiles) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.clearCache(includeDiskFiles);
    }
  }

  @Override
  public void evaluateJavascript(
      Long instanceId, String javascriptString, GeneratedAndroidWebView.Result<String> result) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.evaluateJavascript(javascriptString, result::success);
    }
  }

  @Override
  public String getTitle(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      return webView.getTitle();
    }
    return "";
  }

  @Override
  public void scrollTo(Long instanceId, Long x, Long y) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.scrollTo(x.intValue(), y.intValue());
    }
  }

  @Override
  public void scrollBy(Long instanceId, Long x, Long y) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.scrollBy(x.intValue(), y.intValue());
    }
  }

  @Override
  public Long getScrollX(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      return (long) webView.getScrollX();
    }
    return 0L;
  }

  @Override
  public Long getScrollY(Long instanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      return (long) webView.getScrollY();
    }
    return 0L;
  }

  @NonNull
  @Override
  public GeneratedAndroidWebView.WebViewPoint getScrollPosition(@NonNull Long instanceId) {
    final WebView webView = Objects.requireNonNull(instanceManager.getInstance(instanceId));
    return new GeneratedAndroidWebView.WebViewPoint.Builder()
        .setX((long) webView.getScrollX())
        .setY((long) webView.getScrollY())
        .build();
  }

  @Override
  public void setWebContentsDebuggingEnabled(Boolean enabled) {
    webViewProxy.setWebContentsDebuggingEnabled(enabled);
  }

  @Override
  public void setWebViewClient(Long instanceId, Long webViewClientInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.setWebViewClient((WebViewClient) instanceManager.getInstance(webViewClientInstanceId));
    }
  }

  @Override
  public void addJavaScriptChannel(Long instanceId, Long javaScriptChannelInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    final JavaScriptChannel javaScriptChannel =
        (JavaScriptChannel) instanceManager.getInstance(javaScriptChannelInstanceId);
    if (webView != null) {
      webView.addJavascriptInterface(javaScriptChannel, javaScriptChannel.javaScriptChannelName);
    }
  }

  @Override
  public void removeJavaScriptChannel(Long instanceId, Long javaScriptChannelInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    final JavaScriptChannel javaScriptChannel =
        (JavaScriptChannel) instanceManager.getInstance(javaScriptChannelInstanceId);
    if (webView != null) {
      webView.removeJavascriptInterface(javaScriptChannel.javaScriptChannelName);
    }
  }

  @Override
  public void setDownloadListener(Long instanceId, Long listenerInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.setDownloadListener((DownloadListener) instanceManager.getInstance(listenerInstanceId));
    }
  }

  @Override
  public void setWebChromeClient(Long instanceId, Long clientInstanceId) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.setWebChromeClient((WebChromeClient) instanceManager.getInstance(clientInstanceId));
    }
  }

  @Override
  public void setBackgroundColor(Long instanceId, Long color) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    if (webView != null) {
      webView.setBackgroundColor(color.intValue());
    }
  }

  /** Maintains instances used to communicate with the corresponding WebView Dart object. */
  public InstanceManager getInstanceManager() {
    return instanceManager;
  }
}
