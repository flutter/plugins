package io.flutter.plugins.webviewflutter;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import static io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.view.View;
import android.webkit.WebView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;

public class FlutterWebView implements PlatformView, MethodCallHandler {
  private final WebView webView;
  private final MethodChannel methodChannel;

  @SuppressWarnings("unchecked")
  FlutterWebView(Context context, BinaryMessenger messenger, int id, Map<String, Object> params) {
    webView = new WebView(context);
    if (params.containsKey("initialUrl")) {
      String url = (String) params.get("initialUrl");
      webView.loadUrl(url);
    }
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
      default:
        result.notImplemented();
    }
  }

  private void loadUrl(MethodCall methodCall, Result result) {
    String url = (String) methodCall.arguments;
    webView.loadUrl(url);
    result.success(null);
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
      case 1: //unrestricted
        webView.getSettings().setJavaScriptEnabled(true);
        break;
      default:
        throw new IllegalArgumentException("Trying to set unknown Javascript mode: " + mode);
    }
  }

  @Override
  public void dispose() {}
}
