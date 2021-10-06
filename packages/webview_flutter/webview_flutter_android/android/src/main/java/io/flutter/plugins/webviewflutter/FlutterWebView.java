// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.TargetApi;
import android.content.Context;
import android.hardware.display.DisplayManager;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebStorage;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class FlutterWebView implements PlatformView, MethodCallHandler {

  private static final String JS_CHANNEL_NAMES_FIELD = "javascriptChannelNames";
  private final WebView webView;
  private final MethodChannel methodChannel;
  private final FlutterWebViewClient flutterWebViewClient;
  private final Handler platformThreadHandler;

  // Verifies that a url opened by `Window.open` has a secure url.
  private class FlutterWebChromeClient extends WebChromeClient {

    @Override
    public boolean onCreateWindow(
        final WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
      final WebViewClient webViewClient =
          new WebViewClient() {
            @TargetApi(Build.VERSION_CODES.LOLLIPOP)
            @Override
            public boolean shouldOverrideUrlLoading(
                @NonNull WebView view, @NonNull WebResourceRequest request) {
              final String url = request.getUrl().toString();
              if (!flutterWebViewClient.shouldOverrideUrlLoading(
                  FlutterWebView.this.webView, request)) {
                webView.loadUrl(url);
              }
              return true;
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
              if (!flutterWebViewClient.shouldOverrideUrlLoading(
                  FlutterWebView.this.webView, url)) {
                webView.loadUrl(url);
              }
              return true;
            }
          };

      final WebView newWebView = new WebView(view.getContext());
      newWebView.setWebViewClient(webViewClient);

      final WebView.WebViewTransport transport = (WebView.WebViewTransport) resultMsg.obj;
      transport.setWebView(newWebView);
      resultMsg.sendToTarget();

      return true;
    }

    @Override
    public void onProgressChanged(WebView view, int progress) {
      flutterWebViewClient.onLoadingProgress(progress);
    }
  }

  @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
  @SuppressWarnings("unchecked")
  FlutterWebView(
      final Context context,
      MethodChannel methodChannel,
      Map<String, Object> params,
      View containerView) {

    DisplayListenerProxy displayListenerProxy = new DisplayListenerProxy();
    DisplayManager displayManager =
        (DisplayManager) context.getSystemService(Context.DISPLAY_SERVICE);
    displayListenerProxy.onPreWebViewInitialization(displayManager);

    this.methodChannel = methodChannel;
    this.methodChannel.setMethodCallHandler(this);

    flutterWebViewClient = new FlutterWebViewClient(methodChannel);

    FlutterDownloadListener flutterDownloadListener =
        new FlutterDownloadListener(flutterWebViewClient);
    webView =
        createWebView(
            new WebViewBuilder(context, containerView),
            params,
            new FlutterWebChromeClient(),
            flutterDownloadListener);
    flutterDownloadListener.setWebView(webView);

    displayListenerProxy.onPostWebViewInitialization(displayManager);

    platformThreadHandler = new Handler(context.getMainLooper());

    Map<String, Object> settings = (Map<String, Object>) params.get("settings");
    if (settings != null) {
      applySettings(webView, settings);
    }

    if (params.containsKey(JS_CHANNEL_NAMES_FIELD)) {
      List<String> names = (List<String>) params.get(JS_CHANNEL_NAMES_FIELD);
      if (names != null) {
        registerJavaScriptChannelNames(webView, names);
      }
    }

    Integer autoMediaPlaybackPolicy = (Integer) params.get("autoMediaPlaybackPolicy");
    if (autoMediaPlaybackPolicy != null) {
      updateAutoMediaPlaybackPolicy(webView, autoMediaPlaybackPolicy);
    }
    if (params.containsKey("userAgent")) {
      String userAgent = (String) params.get("userAgent");
      updateUserAgent(webView, userAgent);
    }
    if (params.containsKey("initialUrl")) {
      String url = (String) params.get("initialUrl");
      webView.loadUrl(url);
    }
  }

  /**
   * Creates a {@link android.webkit.WebView} and configures it according to the supplied
   * parameters.
   *
   * <p>The {@link WebView} is configured with the following predefined settings:
   *
   * <ul>
   *   <li>always enable the DOM storage API;
   *   <li>always allow JavaScript to automatically open windows;
   *   <li>always allow support for multiple windows;
   *   <li>always use the {@link FlutterWebChromeClient} as web Chrome client.
   * </ul>
   *
   * <p><strong>Important:</strong> This method is visible for testing purposes only and should
   * never be called from outside this class.
   *
   * @param webViewBuilder a {@link WebViewBuilder} which is responsible for building the {@link
   *     WebView}.
   * @param params creation parameters received over the method channel.
   * @param webChromeClient an implementation of WebChromeClient This value may be null.
   * @return The new {@link android.webkit.WebView} object.
   */
  @VisibleForTesting
  static WebView createWebView(
      WebViewBuilder webViewBuilder,
      Map<String, Object> params,
      WebChromeClient webChromeClient,
      @Nullable DownloadListener downloadListener) {
    boolean usesHybridComposition = Boolean.TRUE.equals(params.get("usesHybridComposition"));
    webViewBuilder
        .setUsesHybridComposition(usesHybridComposition)
        .setDomStorageEnabled(true) // Always enable DOM storage API.
        .setJavaScriptCanOpenWindowsAutomatically(
            true) // Always allow automatically opening of windows.
        .setSupportMultipleWindows(true) // Always support multiple windows.
        .setWebChromeClient(webChromeClient)
        .setDownloadListener(
            downloadListener); // Always use {@link FlutterWebChromeClient} as web Chrome client.

    return webViewBuilder.build();
  }

  @Override
  public View getView() {
    return webView;
  }

  @Override
  public void onInputConnectionUnlocked() {
    if (webView instanceof InputAwareWebView) {
      ((InputAwareWebView) webView).unlockInputConnection();
    }
  }

  @Override
  public void onInputConnectionLocked() {
    if (webView instanceof InputAwareWebView) {
      ((InputAwareWebView) webView).lockInputConnection();
    }
  }

  @Override
  public void onFlutterViewAttached(View flutterView) {
    if (webView instanceof InputAwareWebView) {
      ((InputAwareWebView) webView).setContainerView(flutterView);
    }
  }

  @Override
  public void onFlutterViewDetached() {
    if (webView instanceof InputAwareWebView) {
      ((InputAwareWebView) webView).setContainerView(null);
    }
  }

  @Override
  public void onMethodCall(MethodCall methodCall, Result result) {
    switch (methodCall.method) {
      case "loadUrl":
        {
          Map<String, Object> request = methodCall.arguments();
          String url = (String) request.get("url");
          Map<String, String> headers = (Map<String, String>) request.get("headers");
          if (headers == null) {
            headers = Collections.emptyMap();
          }
          loadUrl(webView, url, headers);
          result.success(null);
          break;
        }
      case "updateSettings":
        updateSettings(webView, methodCall.<Map<String, Object>>arguments());
        result.success(null);
        break;
      case "canGoBack":
        result.success(canGoBack(webView));
        break;
      case "canGoForward":
        result.success(canGoForward(webView));
        break;
      case "goBack":
        goBack(webView);
        result.success(null);
        break;
      case "goForward":
        goForward(webView);
        result.success(null);
        break;
      case "reload":
        reload(webView);
        result.success(null);
        break;
      case "currentUrl":
        result.success(currentUrl(webView));
        break;
      case "evaluateJavascript":
        evaluateJavaScript(webView, methodCall.<String>arguments(), result);
        break;
      case "addJavascriptChannels":
        addJavaScriptChannels(webView, methodCall.<List<String>>arguments());
        result.success(null);
        break;
      case "removeJavascriptChannels":
        removeJavaScriptChannels(webView, methodCall.<List<String>>arguments());
        result.success(null);
        break;
      case "clearCache":
        clearCache(webView);
        result.success(null);
        break;
      case "getTitle":
        result.success(getTitle(webView));
        break;
      case "scrollTo":
        {
          Map<String, Object> request = methodCall.arguments();
          scrollTo(webView, (int) request.get("x"), (int) request.get("y"));
          result.success(null);
          break;
        }
      case "scrollBy":
        {
          Map<String, Object> request = methodCall.arguments();
          scrollBy(webView, (int) request.get("x"), (int) request.get("y"));
          result.success(null);
          break;
        }
      case "getScrollX":
        result.success(getScrollX(webView));
        break;
      case "getScrollY":
        result.success(getScrollY(webView));
        break;
      default:
        result.notImplemented();
    }
  }

  private void loadUrl(WebView webView, String url, Map<String, String> headers) {
    webView.loadUrl(url, headers);
  }

  private boolean canGoBack(WebView webView) {
    return webView.canGoBack();
  }

  private boolean canGoForward(WebView webView) {
    return webView.canGoForward();
  }

  private void goBack(WebView webView) {
    if (webView.canGoBack()) {
      webView.goBack();
    }
  }

  private void goForward(WebView webView) {
    if (!webView.canGoForward()) webView.goForward();
  }

  private void reload(WebView webView) {
    webView.reload();
  }

  private String currentUrl(WebView webView) {
    return webView.getUrl();
  }

  private void updateSettings(WebView webView, Map<String, Object> settings) {
    applySettings(webView, settings);
  }

  @TargetApi(Build.VERSION_CODES.KITKAT)
  private void evaluateJavaScript(WebView webView, String jsString, final Result result) {
    if (jsString == null) {
      throw new UnsupportedOperationException("JavaScript string cannot be null");
    }
    webView.evaluateJavascript(
        jsString,
        new android.webkit.ValueCallback<String>() {
          @Override
          public void onReceiveValue(String value) {
            result.success(value);
          }
        });
  }

  @SuppressWarnings("unchecked")
  private void addJavaScriptChannels(WebView webView, List<String> channelNames) {
    registerJavaScriptChannelNames(webView, channelNames);
  }

  @SuppressWarnings("unchecked")
  private void removeJavaScriptChannels(WebView webView, List<String> channelNames) {
    for (String channelName : channelNames) {
      webView.removeJavascriptInterface(channelName);
    }
  }

  private void clearCache(WebView webView) {
    webView.clearCache(true);
    WebStorage.getInstance().deleteAllData();
  }

  private String getTitle(WebView webView) {
    return webView.getTitle();
  }

  private void scrollTo(WebView webView, int x, int y) {
    webView.scrollTo(x, y);
  }

  private void scrollBy(WebView webView, int x, int y) {
    webView.scrollBy(x, y);
  }

  private int getScrollX(WebView webView) {
    return webView.getScrollX();
  }

  private int getScrollY(WebView webView) {
    return webView.getScrollY();
  }

  private void applySettings(WebView webView, Map<String, Object> settings) {
    for (String key : settings.keySet()) {
      switch (key) {
        case "jsMode":
          Integer mode = (Integer) settings.get(key);
          if (mode != null) {
            updateJsMode(webView, mode);
          }
          break;
        case "hasNavigationDelegate":
          final boolean hasNavigationDelegate = (boolean) settings.get(key);

          final WebViewClient webViewClient =
              flutterWebViewClient.createWebViewClient(hasNavigationDelegate);

          webView.setWebViewClient(webViewClient);
          break;
        case "debuggingEnabled":
          final boolean debuggingEnabled = (boolean) settings.get(key);

          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            webView.setWebContentsDebuggingEnabled(debuggingEnabled);
          }
          break;
        case "hasProgressTracking":
          flutterWebViewClient.hasProgressTracking = (boolean) settings.get(key);
          break;
        case "gestureNavigationEnabled":
          break;
        case "userAgent":
          updateUserAgent(webView, (String) settings.get(key));
          break;
        case "allowsInlineMediaPlayback":
          // no-op inline media playback is always allowed on Android.
          break;
        default:
          throw new IllegalArgumentException("Unknown WebView setting: " + key);
      }
    }
  }

  private void updateJsMode(WebView webView, int mode) {
    switch (mode) {
      case 0: // disabled
        webView.getSettings().setJavaScriptEnabled(false);
        break;
      case 1: // unrestricted
        webView.getSettings().setJavaScriptEnabled(true);
        break;
      default:
        throw new IllegalArgumentException("Trying to set unknown JavaScript mode: " + mode);
    }
  }

  private void updateAutoMediaPlaybackPolicy(WebView webView, int mode) {
    // This is the index of the AutoMediaPlaybackPolicy enum, index 1 is always_allow, for all
    // other values we require a user gesture.
    boolean requireUserGesture = mode != 1;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
      webView.getSettings().setMediaPlaybackRequiresUserGesture(requireUserGesture);
    }
  }

  private void registerJavaScriptChannelNames(WebView webView, List<String> channelNames) {
    for (String channelName : channelNames) {
      webView.addJavascriptInterface(
          new JavaScriptChannel(methodChannel, channelName, platformThreadHandler), channelName);
    }
  }

  private void updateUserAgent(WebView webView, String userAgent) {
    webView.getSettings().setUserAgentString(userAgent);
  }

  @Override
  public void dispose() {
    methodChannel.setMethodCallHandler(null);
    if (webView instanceof InputAwareWebView) {
      ((InputAwareWebView) webView).dispose();
    }
    webView.destroy();
  }
}
