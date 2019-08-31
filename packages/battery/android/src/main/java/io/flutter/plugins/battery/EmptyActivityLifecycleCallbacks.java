package io.flutter.plugins.battery;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
/**
 * Helper class to avoid overriding all methods when we only need one or two. This should probably
 * go to flutter embedding or something.
 */
public abstract class EmptyActivityLifecycleCallbacks
    implements Application.ActivityLifecycleCallbacks {
  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

  @Override
  public void onActivityStarted(Activity activity) {}

  @Override
  public void onActivityResumed(Activity activity) {}

  @Override
  public void onActivityPaused(Activity activity) {}

  @Override
  public void onActivityStopped(Activity activity) {}

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

  @Override
  public void onActivityDestroyed(Activity activity) {}
}
