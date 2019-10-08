package io.flutter.plugins.urllauncher;

import android.support.annotation.NonNull;
import android.util.Log;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/**
 * Plugin implementation that uses the new {@code io.flutter.embedding} package.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public final class UrlLauncherPlugin implements FlutterPlugin, ActivityAware {
  private static final String TAG = "UrlLauncherPlugin";
  private @Nullable MethodCallHandlerImpl methodCallHandler;
  private @Nullable UrlLauncher urlLauncher;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code dev.flutter.plugins.urllauncherexample.MainActivity} for an example.
   */
  public UrlLauncherPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    urlLauncher = new UrlLauncher(binding.getApplicationContext(), /*activity=*/ null);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
    methodCallHandler.startListening(binding.getFlutterEngine().getDartExecutor());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (methodCallHandler == null) {
      Log.wtf(TAG, "Already detached from the engine.");
      return;
    }

    methodCallHandler.stopListening();
    methodCallHandler = null;
    urlLauncher = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    if (methodCallHandler == null) {
      Log.wtf(TAG, "urlLauncher was never set.");
      return;
    }

    urlLauncher.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    if (methodCallHandler == null) {
      Log.wtf(TAG, "urlLauncher was never set.");
      return;
    }

    urlLauncher.setActivity(null);
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
