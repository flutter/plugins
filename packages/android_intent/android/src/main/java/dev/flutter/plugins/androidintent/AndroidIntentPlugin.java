package dev.flutter.plugins.androidintent;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>This can be included in an add to app scenario to gracefully handle activity and context
 * changes, unlike the previous {@link io.flutter.plugins.androidintent.AndroidIntentPlugin}.
 */
public final class AndroidIntentPlugin implements FlutterPlugin, ActivityAware {
  private final IntentSender sender;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code dev.flutter.plugins.androidintentexample.MainActivity} for an example.
   */
  public AndroidIntentPlugin() {
    sender = new IntentSender(/*activity=*/ null, /*context=*/ null);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    sender.setApplicationContext(binding.getApplicationContext());
    sender.setActivity(null);
    MethodChannel channel =
        new MethodChannel(
            binding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/android_intent");
    channel.setMethodCallHandler(new MethodCallHandlerImpl(sender));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    sender.setApplicationContext(null);
    sender.setActivity(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    sender.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    sender.setActivity(null);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }
}
