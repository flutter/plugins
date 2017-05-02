package io.flutter.plugins.path_provider;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.util.PathUtils;


public class PathProviderPlugin implements MethodCallHandler {
  private FlutterActivity activity;

  public static PathProviderPlugin register(FlutterActivity activity) {
    return new PathProviderPlugin(activity);
  }

  private PathProviderPlugin(FlutterActivity activity) {
    this.activity = activity;
    new MethodChannel(activity.getFlutterView(), "plugins.flutter.io/path_provider").
            setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getTemporaryDirectory")) {
      result.success(getPathProviderTemporaryDirectory());
    } else if (call.method.equals("getApplicationDocumentsDirectory")) {
      result.success(getPathProviderApplicationDocumentsDirectory());
    } else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  private String getPathProviderTemporaryDirectory() {
    return activity.getCacheDir().getPath();
  }

  private String getPathProviderApplicationDocumentsDirectory() {
    return PathUtils.getDataDirectory(activity);
  }

}
