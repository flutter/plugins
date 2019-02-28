package io.flutter.plugins.webviewflutter;

import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;
import android.webkit.HttpAuthHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugin.common.MethodChannel;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/** WebViewClient implementation for forwarding notifications to flutter channel. */
public class FlutterWebViewClient extends WebViewClient {

  private static final String TAG = "FlutterWebViewClient";

  private final MethodChannel methodChannel;

  FlutterWebViewClient(MethodChannel methodChannel) {
    this.methodChannel = methodChannel;
  }

  @Override
  public void onPageFinished(WebView view, String url) {
    Log.d(TAG, "onPageFinished: " + url);
    this.methodChannel.invokeMethod("onPageFinished", Collections.singletonMap("url", url));
  }

  @Override
  public void onPageStarted(WebView view, String url, Bitmap favicon) {
    this.methodChannel.invokeMethod("onPageStarted", Collections.singletonMap("url", url));
  }

  @Override
  public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
    Log.d(TAG, "onReceivedError: received error." + error);
    Map<String, String> map = new HashMap<>();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      map.put("url", request.getUrl().toString());
      map.put("description", error.getDescription().toString());
    } else {
      map.put("description", error.toString());
    }
    this.methodChannel.invokeMethod("onReceivedError", map);
  }

  @Override
  public void onReceivedHttpAuthRequest(
      WebView view, final HttpAuthHandler handler, String host, String realm) {
    HashMap<String, String> arguments = new HashMap<>();
    arguments.put("host", host);
    arguments.put("realm", realm);
    methodChannel.invokeMethod(
        "onReceivedHttpAuthRequest",
        arguments,
        new MethodChannel.Result() {
          @Override
          public void success(Object o) {
            if (o instanceof Map) {
              Map<?, ?> map = (Map<?, ?>) o;
              Object username = map.get("username");
              Object password = map.get("password");
              if (username != null && password != null) {
                handler.proceed(username.toString(), password.toString());
                return;
              }
            }
            handler.cancel();
          }

          @Override
          public void error(String s, String s1, Object o) {
            handler.cancel();
          }

          @Override
          public void notImplemented() {
            handler.cancel();
          }
        });
  }
}
