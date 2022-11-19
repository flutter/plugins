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
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebViewHostApi;
import io.flutter.plugins.webviewflutter.WebChromeClientHostApiImpl.WebChromeClientImpl;
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
  private final BinaryMessenger binaryMessenger;

  private Context context;

  /** Handles creating and calling static methods for {@link WebView}s. */
  public static class WebViewProxy {
    /**
     * Creates a {@link WebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets
     * @param binaryMessenger used to communicate with Dart over asynchronous messages
     * @param instanceManager mangages instances used to communicate with the corresponding objects
     *     in Dart
     * @return the created {@link WebViewPlatformView}
     */
    public WebViewPlatformView createWebView(
        Context context, BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
      return new WebViewPlatformView(context, binaryMessenger, instanceManager);
    }

    /**
     * Creates a {@link InputAwareWebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets
     * @param containerView parent View of the WebView
     * @return the created {@link InputAwareWebViewPlatformView}
     */
    public InputAwareWebViewPlatformView createInputAwareWebView(
        Context context,
        BinaryMessenger binaryMessenger,
        InstanceManager instanceManager,
        @Nullable View containerView) {
      return new InputAwareWebViewPlatformView(
          context, binaryMessenger, instanceManager, containerView);
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

  /** Implementation of {@link WebView} that can be used as a Flutter {@link PlatformView}s. */
  public static class WebViewPlatformView extends WebView implements PlatformView {
    private WebViewClient currentWebViewClient;
    private WebChromeClientImpl currentWebChromeClient;

    /**
     * Creates a {@link WebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets. This value cannot be null.
     */
    public WebViewPlatformView(
        Context context, BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
      super(context);
      currentWebViewClient = new WebViewClient();
      currentWebChromeClient =
          new WebChromeClientImpl(
              new WebChromeClientFlutterApiImpl(binaryMessenger, instanceManager));

      setWebViewClient(currentWebViewClient);
      setWebChromeClient(currentWebChromeClient);
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
      currentWebViewClient = webViewClient;
      currentWebChromeClient.setWebViewClient(webViewClient);
    }

    @Override
    public void setWebChromeClient(WebChromeClient client) {
      super.setWebChromeClient(client);
      if (!(client instanceof WebChromeClientImpl)) {
        throw new AssertionError("Client must be a WebChromeClientImpl.");
      }
      currentWebChromeClient = (WebChromeClientImpl) client;
      currentWebChromeClient.setWebViewClient(currentWebViewClient);
    }
  }

  /**
   * Implementation of {@link InputAwareWebView} that can be used as a Flutter {@link
   * PlatformView}s.
   */
  @SuppressLint("ViewConstructor")
  public static class InputAwareWebViewPlatformView extends InputAwareWebView
      implements PlatformView {
    private WebViewClient currentWebViewClient;
    private WebChromeClientImpl currentWebChromeClient;

    /**
     * Creates a {@link InputAwareWebViewPlatformView}.
     *
     * @param context an Activity Context to access application assets. This value cannot be null.
     */
    public InputAwareWebViewPlatformView(
        Context context,
        BinaryMessenger binaryMessenger,
        InstanceManager instanceManager,
        View containerView) {
      super(context, containerView);
      currentWebViewClient = new WebViewClient();
      currentWebChromeClient =
          new WebChromeClientImpl(
              new WebChromeClientFlutterApiImpl(binaryMessenger, instanceManager));

      setWebViewClient(currentWebViewClient);
      setWebChromeClient(currentWebChromeClient);
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
      currentWebViewClient = webViewClient;
      currentWebChromeClient.setWebViewClient(webViewClient);
    }

    @Override
    public void setWebChromeClient(WebChromeClient client) {
      super.setWebChromeClient(client);
      if (!(client instanceof WebChromeClientImpl)) {
        throw new AssertionError("Client must be a WebChromeClientImpl.");
      }
      currentWebChromeClient = (WebChromeClientImpl) client;
      currentWebChromeClient.setWebViewClient(currentWebViewClient);
    }
  }

  /**
   * Creates a host API that handles creating {@link WebView}s and invoking its methods.
   *
   * @param instanceManager maintains instances stored to communicate with Dart objects
   * @param binaryMessenger used to communicate with Dart over asynchronous messages
   * @param webViewProxy handles creating {@link WebView}s and calling its static methods
   * @param context an Activity Context to access application assets. This value cannot be null.
   * @param containerView parent of the webView
   */
  public WebViewHostApiImpl(
      InstanceManager instanceManager,
      BinaryMessenger binaryMessenger,
      WebViewProxy webViewProxy,
      Context context,
      @Nullable View containerView) {
    this.instanceManager = instanceManager;
    this.binaryMessenger = binaryMessenger;
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
            ? webViewProxy.createWebView(context, binaryMessenger, instanceManager)
            : webViewProxy.createInputAwareWebView(
                context, binaryMessenger, instanceManager, containerView);

    displayListenerProxy.onPostWebViewInitialization(displayManager);
    instanceManager.addDartCreatedInstance(webView, instanceId);
  }

  @Override
  public void loadData(Long instanceId, String data, String mimeType, String encoding) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.loadData(data, mimeType, encoding);
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
    webView.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
  }

  @Override
  public void loadUrl(Long instanceId, String url, Map<String, String> headers) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.loadUrl(url, headers);
  }

  @Override
  public void postUrl(Long instanceId, String url, byte[] data) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.postUrl(url, data);
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
    webView.setWebChromeClient((WebChromeClient) instanceManager.getInstance(clientInstanceId));
  }

  @Override
  public void setBackgroundColor(Long instanceId, Long color) {
    final WebView webView = (WebView) instanceManager.getInstance(instanceId);
    webView.setBackgroundColor(color.intValue());
  }

  /** Maintains instances used to communicate with the corresponding WebView Dart object. */
  public InstanceManager getInstanceManager() {
    return instanceManager;
  }
}
