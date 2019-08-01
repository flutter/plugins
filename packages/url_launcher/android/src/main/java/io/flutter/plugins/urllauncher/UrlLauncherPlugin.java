// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Browser;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
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
    final String url = call.argument("url");
    switch (call.method) {
      case "canLaunch":
        canLaunch(url, result);
        break;
      case "launch":
        launch(call, result, url);
        break;
      case "closeWebView":
        closeWebView(result);
        break;
      default:
        result.notImplemented();
        break;
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
    final Bundle headersBundle = extractBundle(headersMap);
    final Context context = mRegistrar.activity();

    if (context == null) {
      result.error("NO_ACTIVITY", "Launching a URL requires a foreground activity.", null);
      return;
    }

    if (useWebView) {
      launchIntent =
          WebViewActivity.createIntent(
              context, url, enableJavaScript, enableDomStorage, headersBundle);
    } else {
      launchIntent =
          new Intent(Intent.ACTION_VIEW)
              .setData(Uri.parse(url))
              .putExtra(Browser.EXTRA_HEADERS, headersBundle);
    }

    context.startActivity(launchIntent);
    result.success(true);
  }

  private void closeWebView(Result result) {
    Intent intent = new Intent(WebViewActivity.ACTION_CLOSE);
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
}
