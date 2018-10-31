// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.KeyEvent;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** UrlLauncherPlugin */
public class UrlLauncherPlugin implements MethodCallHandler {
  private final Registrar mRegistrar;

  public static void registerWith(Registrar registrar) {
    MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/url_launcher");
    UrlLauncherPlugin instance = new UrlLauncherPlugin(registrar);
    channel.setMethodCallHandler(instance);
  }

  private UrlLauncherPlugin(Registrar registrar) {
    this.mRegistrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String url = call.argument("url");
    if (call.method.equals("canLaunch")) {
      canLaunch(url, result);
    } else if (call.method.equals("launch")) {
      Intent launchIntent;
      boolean useWebView = call.argument("useWebView");
      boolean enableJavaScript = call.argument("enableJavaScript");
      Context context;
      if (mRegistrar.activity() != null) {
        context = (Context) mRegistrar.activity();
      } else {
        context = mRegistrar.context();
      }
      if (useWebView) {
        launchIntent = new Intent(context, WebViewActivity.class);
        launchIntent.putExtra("url", url);
        launchIntent.putExtra("enableJavaScript", enableJavaScript);
      } else {
        launchIntent = new Intent(Intent.ACTION_VIEW);
        launchIntent.setData(Uri.parse(url));
      }
      if (mRegistrar.activity() == null) {
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      }
      context.startActivity(launchIntent);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  private void canLaunch(String url, Result result) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(url));
    ComponentName componentName =
        launchIntent.resolveActivity(mRegistrar.context().getPackageManager());

    boolean canLaunch =
        componentName != null
            && !"{com.android.fallback/com.android.fallback.Fallback}"
                .equals(componentName.toShortString());
    result.success(canLaunch);
  }

  /*  Launches WebView activity */
  public static class WebViewActivity extends Activity {
    private WebView webview;

    @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      webview = new WebView(this);
      setContentView(webview);
      // Get the Intent that started this activity and extract the string
      Intent intent = getIntent();
      String url = intent.getStringExtra("url");
      Boolean enableJavaScript = intent.getBooleanExtra("enableJavaScript", false);
      webview.loadUrl(url);
      if (enableJavaScript) {
        webview.getSettings().setJavaScriptEnabled(enableJavaScript);
      }
      // Open new urls inside the webview itself.
      webview.setWebViewClient(
          new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
              view.loadUrl(request.getUrl().toString());
              return false;
            }
          });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
      if (keyCode == KeyEvent.KEYCODE_BACK && webview.canGoBack()) {
        webview.goBack();
        return true;
      }
      return super.onKeyDown(keyCode, event);
    }
  }
}
