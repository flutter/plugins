package dev.flutter.plugins.share;

import android.app.Activity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.share.MethodCallHandler;
import io.flutter.plugins.share.Share;

/**
 * Entry point of the plugin.
 *
 * <p>set up the {@link io.flutter.plugin.common.MethodChannel.MethodCallHandler} during {@link
 * #onAttachedToEngine(FlutterPluginBinding)}. It also implements {@link ActivityAware}, provides
 * the activity instance to {@link Share} when it's available.
 */
public class SharePlugin implements FlutterPlugin, ActivityAware {

  private static final String CHANNEL = "plugins.flutter.io/share";
  private MethodCallHandler handler;
  private Activity activity;
  private Share share;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final MethodChannel methodChannel =
        new MethodChannel(binding.getFlutterEngine().getDartExecutor(), CHANNEL);
    share = new Share(activity);
    handler = new MethodCallHandler(share);
    methodChannel.setMethodCallHandler(handler);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activity = binding.getActivity();
    share.setActivity(activity);
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
    share.setActivity(null);
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
