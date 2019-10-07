package dev.flutter.plugins.sharedpreferences;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.sharedpreferences.MethodCallHandlerImpl;

/**
 * Entry point of the plugin. It sets up the method call handler in {@link
 * #onAttachedToEngine(FlutterPluginBinding)}.
 */
public class SharedPreferencesPlugin implements FlutterPlugin {

  private static final String CHANNEL_NAME = "plugins.flutter.io/shared_preferences";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    MethodChannel channel =
        new MethodChannel(binding.getFlutterEngine().getDartExecutor(), CHANNEL_NAME);
    MethodCallHandlerImpl handler = new MethodCallHandlerImpl(binding.getApplicationContext());
    channel.setMethodCallHandler(handler);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}
}
