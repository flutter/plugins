// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Browser;
import android.view.KeyEvent;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Map;

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
      launch(call, result, url);
    } else if (call.method.equals("closeWebView")) {
      closeWebView(result);
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

  private void launch(MethodCall call, Result result, String url) {
    Intent launchIntent;
    final boolean useWebView = call.argument("useWebView");
    final boolean enableJavaScript = call.argument("enableJavaScript");
    final boolean enableDomStorage = call.argument("enableDomStorage");
    final Map<String, String> headersMap = call.argument("headers");
    final Activity activity = mRegistrar.activity();

    if (activity == null) {
      result.error("NO_ACTIVITY", "Launching a URL requires a foreground activity.", null);
      return;
    }
    if (useWebView) {
      launchIntent = new Intent(activity, WebViewActivity.class);
      launchIntent.putExtra("url", url);
      launchIntent.putExtra("enableJavaScript", enableJavaScript);
      launchIntent.putExtra("enableDomStorage", enableDomStorage);
    } else {
      launchIntent = new Intent(Intent.ACTION_VIEW);
      launchIntent.setData(Uri.parse(url));
    }

    final Bundle headersBundle = extractBundle(headersMap);
    launchIntent.putExtra(Browser.EXTRA_HEADERS, headersBundle);

    activity.startActivity(launchIntent);
    result.success(true);
  }

  private void closeWebView(Result result) {
    Intent intent = new Intent("close");
    mRegistrar.context().sendBroadcast(intent);
    result.success(null);
  }

  private Bundle extractBundle(Map<String, String> headersMap) {
    final Bundle headersBundle = new Bundle();
    for (String key : headersMap.keySet()) {
      final String value = headersMap.get(key);
      headersBundle.putString(key, value);
    }
    return headersBundle;
  }

  /*  Launches WebView activity */
  public static class WebViewActivity extends Activity {
    private WebView webview;
    private BroadcastReceiver broadcastReceiver;

    @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      webview = new WebView(this);
      setContentView(webview);
      // Get the Intent that started this activity and extract the string
      final Intent intent = getIntent();
      final String url = intent.getStringExtra("url");
      final boolean enableJavaScript = intent.getBooleanExtra("enableJavaScript", false);
      final boolean enableDomStorage = intent.getBooleanExtra("enableDomStorage", false);
      final Bundle headersBundle = intent.getBundleExtra(Browser.EXTRA_HEADERS);

      final Map<String, String> headersMap = extractHeaders(headersBundle);
      webview.loadUrl(url, headersMap);

      webview.getSettings().setJavaScriptEnabled(enableJavaScript);
      webview.getSettings().setDomStorageEnabled(enableDomStorage);

      // Open new urls inside the webview itself.
      webview.setWebViewClient(
          new WebViewClient() {

            @Override
            @SuppressWarnings("deprecation")
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
              if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                view.loadUrl(url);
                return false;
              }
              return super.shouldOverrideUrlLoading(view, url);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                view.loadUrl(request.getUrl().toString());
              }
              return false;
            }
          });

      // Set broadcast receiver to handle calls to close the web view
      broadcastReceiver =
          new BroadcastReceiver() {
            @Override
            public void onReceive(Context arg0, Intent intent) {
              String action = intent.getAction();
              if ("close".equals(action)) {
                finish();
              }
            }
          };
      registerReceiver(broadcastReceiver, new IntentFilter("close"));
    }

    private Map<String, String> extractHeaders(Bundle headersBundle) {
      final Map<String, String> headersMap = new HashMap<>();
      for (String key : headersBundle.keySet()) {
        final String value = headersBundle.getString(key);
        headersMap.put(key, value);
      }
      return headersMap;
    }

    @Override
    protected void onDestroy() {
      super.onDestroy();
      unregisterReceiver(broadcastReceiver);
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
