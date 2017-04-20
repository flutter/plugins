package io.flutter.plugins.url_launcher;

import android.content.Intent;
import android.net.Uri;

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
    if (call.method.equals("UrlLauncher.launch")) {
      launchURL((String) call.arguments);
      result.success(null);
    } else {
      result.notImplemented();
    }
  }
  private void launchURL(String url) {
    try {
      Intent launchIntent = new Intent(Intent.ACTION_VIEW);
      launchIntent.setData(Uri.parse(url));
      activity.startActivity(launchIntent);
    } catch (java.lang.Exception exception) {
      // Ignore parsing or ActivityNotFound errors
    }
  }
}
