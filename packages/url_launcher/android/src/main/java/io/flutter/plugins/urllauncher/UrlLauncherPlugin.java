// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.WebView;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** UrlLauncherPlugin */
public class UrlLauncherPlugin implements MethodCallHandler {
  private final Activity activity;

  public static void registerWith(Registrar registrar) {
    MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/url_launcher");
    UrlLauncherPlugin instance = new UrlLauncherPlugin(registrar.activity());
    channel.setMethodCallHandler(instance);
  }

  private UrlLauncherPlugin(Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String url = call.argument("url");
    if (call.method.equals("canLaunch")) {
      canLaunch(url, result);
    } else if (call.method.equals("launch")) {
      Intent launchIntent;
      boolean useWebView = call.argument("useWebView");
      if (useWebView) {
        launchIntent = new Intent(activity, WebViewActivity.class);
        launchIntent.putExtra("url", url);
      } else {
        launchIntent = new Intent(Intent.ACTION_VIEW);
        launchIntent.setData(Uri.parse(url));
      }
      activity.startActivity(launchIntent);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  private void canLaunch(String url, Result result) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(url));
    ComponentName componentName = launchIntent.resolveActivity(activity.getPackageManager());

    boolean canLaunch =
        componentName != null
            && !"{com.android.fallback/com.android.fallback.Fallback}"
                .equals(componentName.toShortString());
    result.success(canLaunch);
  }

  /*  Launches WebView activity */
  public static class WebViewActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      WebView webview = new WebView(this);
      setContentView(webview);
      // Get the Intent that started this activity and extract the string
      Intent intent = getIntent();
      String url = intent.getStringExtra("url");
      webview.loadUrl(url);
    }
  }
}
