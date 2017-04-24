// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.url_launcher;

import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.provider.Settings;

import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;

/**
 * UrlLauncherPlugin
 */
public class UrlLauncherPlugin implements MethodCallHandler {
    private FlutterActivity activity;

    public static UrlLauncherPlugin register(FlutterActivity activity) {
        return new UrlLauncherPlugin(activity);
    }

    private UrlLauncherPlugin(FlutterActivity activity) {
        this.activity = activity;
        new MethodChannel(
                activity.getFlutterView(), "plugins.flutter.io/URLLauncher").setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("UrlLauncher.canLaunch")) {
            //todo upgrade flutter
            canLaunch((String) call.arguments, result);
        } else if (call.method.equals("UrlLauncher.launch")) {
            launchURL((String) call.arguments, result);
        } else {
            result.notImplemented();
        }
    }

    private void launchURL(String url, Result result) {
        try {
            Intent launchIntent = new Intent(Intent.ACTION_VIEW);
            launchIntent.setData(Uri.parse(url));
            activity.startActivity(launchIntent);
            result.success(null);
        } catch (java.lang.Exception exception) {
            result.error("ERROR", exception.getMessage(), null);
        }
    }

    private void canLaunch(String url, Result result) {
        Intent launchIntent = new Intent(Intent.ACTION_VIEW);
        launchIntent.setData(Uri.parse(url));
        ComponentName componentName = launchIntent.resolveActivity(activity.getPackageManager());
        if (componentName == null ||
                "{com.android.fallback/com.android.fallback.Fallback}".
                        equals(componentName.toShortString())) {
            result.success(false);
        }

        result.success(true);

    }
}
