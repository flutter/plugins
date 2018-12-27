package io.flutter.plugins.webviewflutter;

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.os.Build;
import android.util.Log;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

public class FlutterWebViewClient extends WebViewClient {
  private static final String TAG = FlutterWebViewClient.class.getSimpleName();

  private final MethodChannel methodChannel;

  private Boolean shouldOverrideUrlLoading = false;

  FlutterWebViewClient(MethodChannel methodChannel) {
    assert methodChannel != null;
    this.methodChannel = methodChannel;
  }

  @Override
  public boolean shouldOverrideUrlLoading(WebView view, String url) {
    return onShouldOverrideUrlLoading(view, url);
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  @Override
  public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
    return onShouldOverrideUrlLoading(view, request.getUrl().toString());
  }

  private boolean onShouldOverrideUrlLoading(final WebView view, final String url) {
    if (shouldOverrideUrlLoading) {
      Map<String, Object> args = new HashMap<>();
      args.put("url", url);
      methodChannel.invokeMethod(
          "shouldOverrideUrlLoading",
          args,
          new MethodChannel.Result() {
            @Override
            public void success(Object result) {
              shouldOverrideUrlLoading = (Boolean) result;
              if (!shouldOverrideUrlLoading) {
                view.loadUrl(url);
              }
            }

            @Override
            public void error(String errorCode, String errorMessage, Object errorDetails) {
              Log.e(
                  TAG,
                  String.format(
                      "Failed to handle channel reply: %s: %s" + errorCode, errorMessage));
            }

            @Override
            public void notImplemented() {}
          });
      return true;
    } else {
      shouldOverrideUrlLoading = true;
      return false;
    }
  }

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

  @Override
  public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
    super.onReceivedError(view, errorCode, description, failingUrl);

    Map<String, Object> args = new HashMap<>();
    args.put("errorCode", errorCode);
    args.put("description", description);
    args.put("url", failingUrl);
    methodChannel.invokeMethod("onReceivedError", args);
  }

  @TargetApi(Build.VERSION_CODES.M)
  @Override
  public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
    super.onReceivedError(view, request, error);

    Map<String, Object> args = new HashMap<>();
    args.put("errorCode", error.getErrorCode());
    args.put("description", error.getDescription());
    args.put("url", request.getUrl());
    methodChannel.invokeMethod("onReceivedError", args);
  }
}
