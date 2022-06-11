// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Browser;
import android.util.Log;
import androidx.annotation.Nullable;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** Launches components for URLs. */
class UrlLauncher {
  private static final String TAG = "UrlLauncher";
  private final Context applicationContext;

  @Nullable private Activity activity;

  /**
   * Uses the given {@code applicationContext} for launching intents.
   *
   * <p>It may be null initially, but should be set before calling {@link #launch}.
   */
  UrlLauncher(Context applicationContext, @Nullable Activity activity) {
    this.applicationContext = applicationContext;
    this.activity = activity;
  }

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  /** Returns whether the given {@code url} resolves into an existing component. */
  boolean canLaunch(String url) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(url));
    ComponentName componentName =
        launchIntent.resolveActivity(applicationContext.getPackageManager());

    if (componentName == null) {
      Log.i(TAG, "component name for " + url + " is null");
      return false;
    } else {
      Log.i(TAG, "component name for " + url + " is " + componentName.toShortString());
      return !"{com.android.fallback/com.android.fallback.Fallback}"
          .equals(componentName.toShortString());
    }
  }

  /**
   * Attempts to launch the given {@code url}.
   *
   * @param headersBundle forwarded to the intent as {@code Browser.EXTRA_HEADERS}.
   * @param useWebView when true, the URL is launched inside of {@link WebViewActivity}.
   * @param enableJavaScript Only used if {@param useWebView} is true. Enables JS in the WebView.
   * @param enableDomStorage Only used if {@param useWebView} is true. Enables DOM storage in the
   *     WebView.
   * @param universalLinksOnly Only used if {@param useWebView} is false. When true, will only
   *     launch if an app is available that is not a browser.
   * @return {@link LaunchStatus#NO_ACTIVITY} if there's no available {@code applicationContext}.
   *     {@link LaunchStatus#ACTIVITY_NOT_FOUND} if there's no activity found to handle {@code
   *     launchIntent}. {@link LaunchStatus#OK} otherwise.
   */
  LaunchStatus launch(
      String url,
      Bundle headersBundle,
      boolean useWebView,
      boolean enableJavaScript,
      boolean enableDomStorage,
      boolean universalLinksOnly) {
    if (activity == null) {
      return LaunchStatus.NO_ACTIVITY;
    }

    Intent launchIntent;
    if (useWebView) {
      launchIntent =
          WebViewActivity.createIntent(
              activity, url, enableJavaScript, enableDomStorage, headersBundle);
    } else {
      launchIntent =
          new Intent(Intent.ACTION_VIEW)
              .setData(Uri.parse(url))
              .putExtra(Browser.EXTRA_HEADERS, headersBundle);

      if (universalLinksOnly) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
          launchIntent = launchIntent.addFlags(Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER);
        } else {
          Set<String> nonBrowserPackageNames = getNonBrowserPackageNames(launchIntent);
          if (nonBrowserPackageNames.isEmpty()) {
            return LaunchStatus.ACTIVITY_NOT_FOUND;
          }
        }
      }
    }

    try {
      activity.startActivity(launchIntent);
    } catch (ActivityNotFoundException e) {
      return LaunchStatus.ACTIVITY_NOT_FOUND;
    }

    return LaunchStatus.OK;
  }

  private Set<String> getNonBrowserPackageNames(Intent specializedIntent) {
    PackageManager packageManager = applicationContext.getPackageManager();

    // Get all apps that resolve the specific URL.
    Set<String> specializedPackageNames = queryPackageNames(packageManager, specializedIntent);

    // Get all apps that resolve a generic URL.
    Intent genericIntent =
        new Intent().setAction(Intent.ACTION_VIEW).setData(Uri.fromParts("https", "", null));
    Set<String> genericPackageNames = queryPackageNames(packageManager, genericIntent);

    // Keep only the apps that resolve the specific, but not the generic URLs.
    specializedPackageNames.removeAll(genericPackageNames);
    return specializedPackageNames;
  }

  private Set<String> queryPackageNames(PackageManager packageManager, Intent intent) {
    List<ResolveInfo> intentActivities = packageManager.queryIntentActivities(intent, 0);
    Set<String> packageNames = new HashSet<>();
    for (ResolveInfo intentActivity : intentActivities) {
      packageNames.add(intentActivity.activityInfo.packageName);
    }
    return packageNames;
  }

  /** Closes any activities started with {@link #launch} {@code useWebView=true}. */
  void closeWebView() {
    applicationContext.sendBroadcast(new Intent(WebViewActivity.ACTION_CLOSE));
  }

  /** Result of a {@link #launch} call. */
  enum LaunchStatus {
    /** The intent was well formed. */
    OK,
    /** No activity was found to launch. */
    NO_ACTIVITY,
    /** No Activity found that can handle given intent. */
    ACTIVITY_NOT_FOUND,
  }
}
