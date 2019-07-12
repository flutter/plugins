// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static android.content.Context.INPUT_METHOD_SERVICE;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebStorage;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugin.common.BinaryMessenger;
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
  private final InputAwareWebView webView;
  private final MethodChannel methodChannel;
  private final FlutterWebViewClient flutterWebViewClient;
  private final Handler platformThreadHandler;
  private final View flutterView;

  private static class InputAwareWebView extends WebView {
    private static final String TAG = "InputAwareWebView";
    private final View flutterView;

    InputAwareWebView(Context context, View flutterView) {
      super(context);
      this.flutterView = flutterView;
    }

    private View threadedInputConnectionProxyView;

    private ThreadedInputConnectionProxyAdapterView proxyAdapterView;

    @Override
    public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
      if (proxyAdapterView == null) {
        // No proxy adapter set, so we use the default implementation.
        return super.onCreateInputConnection(outAttrs);
      }

      if (!proxyAdapterView.isTriggerDelayed()) {
        // Currently on the IME thread. Delegate to the superclass.
        return super.onCreateInputConnection(outAttrs);
      }

      InputConnection result = super.onCreateInputConnection(outAttrs);
      if (result != null) {
        // This should never happen.
        Log.wtf(TAG, "Failed unexpectedly creating a webview input connection.");
      }

      final InputMethodManager imm =
          (InputMethodManager) getContext().getSystemService(INPUT_METHOD_SERVICE);
      proxyAdapterView.requestFocus();
      final View containerView = this;

      // This is the crucial trick that gets the InputConnection creation to happen on the correct
      // thread. https://cs.chromium.org/chromium/src/content/public/android/java/src/org/chromium/content/browser/input/ThreadedInputConnectionFactory.java?l=169.
      this.post(
          new Runnable() {
            @Override
            public void run() {
              // This is a hack to make InputMethodManager believe that the proxy view now has a focus.
              // As a result, InputMethodManager will think that mProxyView is focused, and will call
              // getHandler() of the view when creating input connection.

              // Step 1: Set proxyAdapterView as InputMethodManager#mNextServedView. This does not
              // affect the real window focus.
              proxyAdapterView.onWindowFocusChanged(true);

              // Step 2: Have InputMethodManager focus in on containerView. As a result, IMM will call
              // onCreateInputConnection() on proxyAdapterView on the same thread as
              // proxyAdapterView.getHandler(). It will also call subsequent InputConnection methods on
              // this IME thread.
              imm.isActive(containerView);
            }
          });
      return null;
    }

    @Override
    public boolean checkInputConnectionProxy(final View view) {
      View previousProxy = threadedInputConnectionProxyView;
      threadedInputConnectionProxyView = view;
      if (previousProxy != view) {
        proxyAdapterView =
            new ThreadedInputConnectionProxyAdapterView(
                /*containerView=*/ flutterView,
                /*targetView=*/ view,
                /*imeHandler=*/ view.getHandler());
        final View container = this;
        proxyAdapterView.requestFocus();
        post(
            new Runnable() {
              @Override
              public void run() {
                InputMethodManager imm =
                    (InputMethodManager) getContext().getSystemService(INPUT_METHOD_SERVICE);
                imm.restartInput(container);
              }
            });
      }
      return super.checkInputConnectionProxy(view);
    }
  }

  @SuppressWarnings("unchecked")
  FlutterWebView(
      Context context,
      BinaryMessenger messenger,
      int id,
      Map<String, Object> params,
      final View flutterView) {
    this.flutterView = flutterView;
    webView = new InputAwareWebView(context, flutterView);

    platformThreadHandler = new Handler(context.getMainLooper());
    // Allow local storage.
    webView.getSettings().setDomStorageEnabled(true);

    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/webview_" + id);
    methodChannel.setMethodCallHandler(this);

    flutterWebViewClient = new FlutterWebViewClient(methodChannel);
    applySettings((Map<String, Object>) params.get("settings"));

    if (params.containsKey(JS_CHANNEL_NAMES_FIELD)) {
      registerJavaScriptChannelNames((List<String>) params.get(JS_CHANNEL_NAMES_FIELD));
    }

    if (params.containsKey("initialUrl")) {
      String url = (String) params.get("initialUrl");
      webView.loadUrl(url);
    }
  }

  @Override
  public View getView() {
    return webView;
  }

  // @Override
  // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
  // annotation would cause compile time failures in versions of Flutter too old to include the new
  // method. However leaving it raw like this means that the method will be ignored in old versions
  // of Flutter but used as an override anyway wherever it's actually defined.
  // TODO(mklim): Add the @Override annotation once flutter/engine#9727 rolls to stable.
  public void onInputConnectionUnlocked() {
    if (webView.proxyAdapterView == null) {
      return;
    }

    webView.proxyAdapterView.setLocked(false);
    InputMethodManager imm =
        (InputMethodManager) flutterView.getContext().getSystemService(INPUT_METHOD_SERVICE);
    imm.restartInput(flutterView);
  }

  // @Override
  // This is overriding a method that hasn't rolled into stable Flutter yet. Including the
  // annotation would cause compile time failures in versions of Flutter too old to include the new
  // method. However leaving it raw like this means that the method will be ignored in old versions
  // of Flutter but used as an override anyway wherever it's actually defined.
  // TODO(mklim): Add the @Override annotation once flutter/engine#9727 rolls to stable.
  public void onInputConnectionLocked() {
    if (webView.proxyAdapterView == null) {
      return;
    }

    webView.proxyAdapterView.setLocked(true);
  }

  @Override
  public void onMethodCall(MethodCall methodCall, Result result) {
    switch (methodCall.method) {
      case "loadUrl":
        loadUrl(methodCall, result);
        break;
      case "updateSettings":
        updateSettings(methodCall, result);
        break;
      case "canGoBack":
        canGoBack(result);
        break;
      case "canGoForward":
        canGoForward(result);
        break;
      case "goBack":
        goBack(result);
        break;
      case "goForward":
        goForward(result);
        break;
      case "reload":
        reload(result);
        break;
      case "currentUrl":
        currentUrl(result);
        break;
      case "evaluateJavascript":
        evaluateJavaScript(methodCall, result);
        break;
      case "addJavascriptChannels":
        addJavaScriptChannels(methodCall, result);
        break;
      case "removeJavascriptChannels":
        removeJavaScriptChannels(methodCall, result);
        break;
      case "clearCache":
        clearCache(result);
        break;
      default:
        result.notImplemented();
    }
  }

  @SuppressWarnings("unchecked")
  private void loadUrl(MethodCall methodCall, Result result) {
    Map<String, Object> request = (Map<String, Object>) methodCall.arguments;
    String url = (String) request.get("url");
    Map<String, String> headers = (Map<String, String>) request.get("headers");
    if (headers == null) {
      headers = Collections.emptyMap();
    }
    webView.loadUrl(url, headers);
    result.success(null);
  }

  private void canGoBack(Result result) {
    result.success(webView.canGoBack());
  }

  private void canGoForward(Result result) {
    result.success(webView.canGoForward());
  }

  private void goBack(Result result) {
    if (webView.canGoBack()) {
      webView.goBack();
    }
    result.success(null);
  }

  private void goForward(Result result) {
    if (webView.canGoForward()) {
      webView.goForward();
    }
    result.success(null);
  }

  private void reload(Result result) {
    webView.reload();
    result.success(null);
  }

  private void currentUrl(Result result) {
    result.success(webView.getUrl());
  }

  @SuppressWarnings("unchecked")
  private void updateSettings(MethodCall methodCall, Result result) {
    applySettings((Map<String, Object>) methodCall.arguments);
    result.success(null);
  }

  @TargetApi(Build.VERSION_CODES.KITKAT)
  private void evaluateJavaScript(MethodCall methodCall, final Result result) {
    String jsString = (String) methodCall.arguments;
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
  private void addJavaScriptChannels(MethodCall methodCall, Result result) {
    List<String> channelNames = (List<String>) methodCall.arguments;
    registerJavaScriptChannelNames(channelNames);
    result.success(null);
  }

  @SuppressWarnings("unchecked")
  private void removeJavaScriptChannels(MethodCall methodCall, Result result) {
    List<String> channelNames = (List<String>) methodCall.arguments;
    for (String channelName : channelNames) {
      webView.removeJavascriptInterface(channelName);
    }
    result.success(null);
  }

  private void clearCache(Result result) {
    webView.clearCache(true);
    WebStorage.getInstance().deleteAllData();
    result.success(null);
  }

  private void applySettings(Map<String, Object> settings) {
    for (String key : settings.keySet()) {
      switch (key) {
        case "jsMode":
          updateJsMode((Integer) settings.get(key));
          break;
        case "hasNavigationDelegate":
          final boolean hasNavigationDelegate = (boolean) settings.get(key);

          final WebViewClient webViewClient =
              flutterWebViewClient.createWebViewClient(hasNavigationDelegate);

          webView.setWebViewClient(webViewClient);
          break;
        case "debuggingEnabled":
          final boolean debuggingEnabled = (boolean) settings.get(key);

          webView.setWebContentsDebuggingEnabled(debuggingEnabled);
          break;
        default:
          throw new IllegalArgumentException("Unknown WebView setting: " + key);
      }
    }
  }

  private void updateJsMode(int mode) {
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

  private void registerJavaScriptChannelNames(List<String> channelNames) {
    for (String channelName : channelNames) {
      webView.addJavascriptInterface(
          new JavaScriptChannel(methodChannel, channelName, platformThreadHandler), channelName);
    }
  }

  @Override
  public void dispose() {
    methodChannel.setMethodCallHandler(null);
  }
}
