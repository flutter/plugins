package io.flutter.plugins.webviewflutter;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.view.View;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformView;

import java.util.HashMap;
import java.util.Map;

public class FlutterWebView implements PlatformView, MethodCallHandler {
  private final WebView webView;
  private final MethodChannel methodChannel;
  private final WebViewClient webClient;
  private String invalidUrlRegex;

  @SuppressWarnings("unchecked")
  FlutterWebView(Context context, final BinaryMessenger messenger, int id, Map<String, Object> params) {
    webView = new WebView(context);
    if (params.containsKey("initialUrl")) {
      String url = (String) params.get("initialUrl");
      webView.loadUrl(url);
    }
    if (params.containsKey("invalidUrlRegex")) {
      invalidUrlRegex = (String) params.get("invalidUrlRegex");
    } else {
      invalidUrlRegex = null;
    }

    webClient = new WebViewClient() {
      @Override
      public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        Map<String, Object> args = new HashMap<>();
        args.put("url", url);
        methodChannel.invokeMethod("onPageStarted", args);
      }

      @Override
      public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        Map<String, Object> args = new HashMap<>();
        args.put("url", url);
        methodChannel.invokeMethod("onPageFinished", args);
      }

      @TargetApi(Build.VERSION_CODES.LOLLIPOP)
      @Override
      public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
        // returning true causes the current WebView to abort loading the URL,
        // while returning false causes the WebView to continue loading the URL as usual.
        String url = request.getUrl().toString();
        onUrlShouldLoad(url);
        return invalidUrlRegex != null && url.matches(invalidUrlRegex);
      }

      @Override
      public boolean shouldOverrideUrlLoading(WebView view, String url) {
        // returning true causes the current WebView to abort loading the URL,
        // while returning false causes the WebView to continue loading the URL as usual.
        onUrlShouldLoad(url);
        return invalidUrlRegex != null && url.matches(invalidUrlRegex);
      }

      private void onUrlShouldLoad(String url) {
        Map<String, Object> args = new HashMap<>();
        args.put("url", url);
        methodChannel.invokeMethod("onUrlShouldLoad", args);
      }
    };
    webView.setWebViewClient(webClient);

    applySettings((Map<String, Object>) params.get("settings"));

    methodChannel = new MethodChannel(messenger, "plugins.flutter.io/webview_" + id);
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public View getView() {
    return webView;
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
        canGoBack(methodCall, result);
        break;
      case "canGoForward":
        canGoForward(methodCall, result);
        break;
      case "goBack":
        goBack(methodCall, result);
        break;
      case "goForward":
        goForward(methodCall, result);
        break;
      case "reload":
        reload(methodCall, result);
        break;
      case "currentUrl":
        currentUrl(methodCall, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void loadUrl(MethodCall methodCall, Result result) {
    String url = (String) methodCall.arguments;
    webView.loadUrl(url);
    result.success(null);
  }

  private void canGoBack(MethodCall methodCall, Result result) {
    result.success(webView.canGoBack());
  }

  private void canGoForward(MethodCall methodCall, Result result) {
    result.success(webView.canGoForward());
  }

  private void goBack(MethodCall methodCall, Result result) {
    if (webView.canGoBack()) {
      webView.goBack();
    }
    result.success(null);
  }

  private void goForward(MethodCall methodCall, Result result) {
    if (webView.canGoForward()) {
      webView.goForward();
    }
    result.success(null);
  }

  private void reload(MethodCall methodCall, Result result) {
    webView.reload();
    result.success(null);
  }

  private void currentUrl(MethodCall methodCall, Result result) {
    result.success(webView.getUrl());
  }

  @SuppressWarnings("unchecked")
  private void updateSettings(MethodCall methodCall, Result result) {
    applySettings((Map<String, Object>) methodCall.arguments);
    result.success(null);
  }

  private void applySettings(Map<String, Object> settings) {
    for (String key : settings.keySet()) {
      switch (key) {
        case "jsMode":
          updateJsMode((Integer) settings.get(key));
          break;
        case "invalidUrlRegex":
          updateInvalidUrlRegex((String) settings.get(key));
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
        throw new IllegalArgumentException("Trying to set unknown Javascript mode: " + mode);
    }
  }

  private void updateInvalidUrlRegex(String regex) {
    invalidUrlRegex = regex;
  }

  @Override
  public void dispose() {}
}
