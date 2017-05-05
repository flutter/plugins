package com.yourcompany.share;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;

/**
 * SharePlugin
 */
public class SharePlugin implements MethodCallHandler {
  private FlutterActivity activity;

  public static SharePlugin register(FlutterActivity activity) {
    return new SharePlugin(activity);
  }

  private SharePlugin(FlutterActivity activity) {
    this.activity = activity;
    new MethodChannel(activity.getFlutterView(), "share").setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }
}
