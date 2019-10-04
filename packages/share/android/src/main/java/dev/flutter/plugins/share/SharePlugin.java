package dev.flutter.plugins.share;

import android.app.Activity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.share.MethodChannelHandler;

/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class SharePlugin implements FlutterPlugin, ActivityAware {

  private static final String CHANNEL = "plugins.flutter.io/share";
  MethodChannelHandler handler;
  Activity activity;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final MethodChannel methodChannel =
        new MethodChannel(binding.getFlutterEngine().getDartExecutor(), CHANNEL);
    handler = new MethodChannelHandler(activity);
    methodChannel.setMethodCallHandler(handler);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activity = binding.getActivity();
    handler.setActivity(activity);
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
    handler.setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }
}
