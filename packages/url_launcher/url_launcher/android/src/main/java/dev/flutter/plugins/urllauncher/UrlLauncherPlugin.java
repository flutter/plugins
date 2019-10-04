package dev.flutter.plugins.urllauncher;

import android.support.annotation.NonNull;
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

  private final MethodCallHandlerImpl methodCallHandler;
  private final UrlLauncher urlLauncher;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code dev.flutter.plugins.urllauncherexample.MainActivity} for an example.
   */
  public UrlLauncherPlugin() {
    urlLauncher = new UrlLauncher(null);
    methodCallHandler = new MethodCallHandlerImpl(urlLauncher);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    methodCallHandler.startListening(binding.getFlutterEngine().getDartExecutor());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodCallHandler.stopListening();
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    urlLauncher.setActivityContext(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    urlLauncher.setActivityContext(null);
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
