// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

public class LifeCycleHelper
    implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
  private final Activity thisActivity;

  LifeCycleHelper(Activity activity) {
    this.thisActivity = activity;
  }

  @Override
  public void onCreate(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStart(@NonNull LifecycleOwner owner) {}

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {}

  @Override
  public void onPause(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStop(@NonNull LifecycleOwner owner) {
    onActivityStopped(thisActivity);
  }

  @Override
  public void onDestroy(@NonNull LifecycleOwner owner) {
    onActivityDestroyed(thisActivity);
  }

  @Override
  public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

  @Override
  public void onActivityStarted(Activity activity) {}

  @Override
  public void onActivityResumed(Activity activity) {}

  @Override
  public void onActivityPaused(Activity activity) {}

  @Override
  public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

  @Override
  public void onActivityDestroyed(Activity activity) {
    if (thisActivity == activity && activity.getApplicationContext() != null) {
      ((Application) activity.getApplicationContext()).unregisterActivityLifecycleCallbacks(this);
    }
  }

  @Override
  public void onActivityStopped(Activity activity) {}
}
