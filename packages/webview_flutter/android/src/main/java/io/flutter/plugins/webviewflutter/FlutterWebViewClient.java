package io.flutter.plugins.webviewflutter;

import android.annotation.TargetApi;
import android.os.Build;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;

class FlutterWebViewClient extends WebViewClient {
  private final MethodChannel methodChannel;
  private boolean hasNavigationDelegate;

  FlutterWebViewClient(MethodChannel methodChannel) {
    this.methodChannel = methodChannel;
  }

  void setHasNavigationDelegate(boolean hasNavigationDelegate) {
    this.hasNavigationDelegate = hasNavigationDelegate;
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  @Override
  public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
    if (!hasNavigationDelegate) {
      return super.shouldOverrideUrlLoading(view, request);
    }
    notifyOnNavigationRequest(request.getUrl().toString(), request.isForMainFrame());
    // We must make a synchronous decision here whether to allow the navigation or not,
    // if there Dart code has set a navigation delegate we want that delegate to decide whether
    // to navigate or not, and as we cannot get a response from the Dart delegate synchronously we
    // return true here to block the navigation, if the Dart delegate decides to allow the
    // navigation the plugin will later make an addition loadUrl call for this url.
    //
    // Since we cannot call loadUrl for a subframe, we currently only allow the delegate to stop
    // navigations that originated in the main frame, if the request is not for the main frame
    // we just return false to allow the navigation.
    //
    // For more details see: https://github.com/flutter/flutter/issues/25329#issuecomment-464863209
    return request.isForMainFrame();
  }

  @Override
  public boolean shouldOverrideUrlLoading(WebView view, String url) {
    if (!hasNavigationDelegate) {
      return super.shouldOverrideUrlLoading(view, url);
    }
    notifyOnNavigationRequest(url, true);
    return true;
  }

  private void notifyOnNavigationRequest(String url, boolean isMainFrame) {
    HashMap<String, Object> args = new HashMap<>();
    args.put("url", url);
    args.put("isMainFrame", isMainFrame);
    methodChannel.invokeMethod("navigationRequest", args);
  }
}
