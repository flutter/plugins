package io.flutter.plugins.webviewflutterexample;

import android.os.Build;
import android.webkit.WebSettings;
import android.webkit.WebView;
import io.flutter.app.FlutterApplication;
import io.flutter.plugins.webviewflutter.FlutterWebView;
import io.flutter.plugins.webviewflutter.FlutterWebViewIniter;

public class App extends FlutterApplication implements FlutterWebViewIniter {
  @Override
  public void onCreate() {
    super.onCreate();

    FlutterWebView.setCommonIniter(this);
  }

  @Override
  public void initWebView(WebView webView) {
    WebSettings settings = webView.getSettings();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      settings.setMixedContentMode(WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE);
    }
    settings.setSupportZoom(true);
    settings.setBuiltInZoomControls(true);
    settings.setDisplayZoomControls(false);
  }
}
