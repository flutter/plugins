package dev.flutter.plugins.urllauncher;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Browser;

/** Launches components for URLs. */
final class UrlLauncher {
  private final Context activityContext;

  /** Uses the given {@code activityContext} for launching intents. */
  UrlLauncher(Context activityContext) {
    this.activityContext = activityContext;
  }

  /** Returns whether the given {@code uri} resolves into an existing component. */
  boolean canLaunch(String uri) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(uri));
    ComponentName componentName = launchIntent.resolveActivity(activityContext.getPackageManager());

    return componentName != null
        && !"{com.android.fallback/com.android.fallback.Fallback}"
            .equals(componentName.toShortString());
  }

  /**
   * Attempts to launch the given {@code url}.
   *
   * @param headersBundle forwarded to the intent as {@code Browser.EXTRA_HEADERS}.
   * @param useWebView when true, the URL is launched inside of {@link WebViewActivity}.
   * @param enableJavaScript Only used if {@param useWebView} is true. Enables JS in the WebView.
   * @param enableDomStorage Only used if {@param useWebView} is true. Enables DOM storage in the
   * @return {@link LaunchStatus#NO_ACTIVITY} if there's no available {@code activityContext}.
   *     {@link LaunchStatus#OK} otherwise.
   */
  LaunchStatus launch(
      String url,
      Bundle headersBundle,
      boolean useWebView,
      boolean enableJavaScript,
      boolean enableDomStorage) {
    if (activityContext == null) {
      return LaunchStatus.NO_ACTIVITY;
    }

    Intent launchIntent;
    if (useWebView) {
      launchIntent =
          WebViewActivity.createIntent(
              activityContext, url, enableJavaScript, enableDomStorage, headersBundle);
    } else {
      launchIntent =
          new Intent(Intent.ACTION_VIEW)
              .setData(Uri.parse(url))
              .putExtra(Browser.EXTRA_HEADERS, headersBundle);
    }

    activityContext.startActivity(launchIntent);
    return LaunchStatus.OK;
  }

  /** Closes any activities started with {@link #launch} {@code useWebView=true}. */
  void closeWebView() {
    activityContext.sendBroadcast(new Intent(WebViewActivity.ACTION_CLOSE));
  }

  /** Result of a {@link #launch} call. */
  enum LaunchStatus {
    /** The intent was well formed. */
    OK,
    /** No activity context was found to launch. */
    NO_ACTIVITY,
  }
}
