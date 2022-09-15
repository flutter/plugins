// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import android.app.Activity;
import android.app.Application;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Move all activity-lifetime-bound states into this helper object, so that {@code setup} and {@code
 * tearDown} would just become constructor and finalize calls of the helper object.
 */
public class ActivityStateHelper {
  private Application application;
  private Activity activity;
  private FileSelectorDelegate delegate;
  private MethodChannel channel;
  private LifeCycleHelper observer;
  private ActivityPluginBinding activityBinding;

  // This is null when not using v2 embedding;
  private Lifecycle lifecycle;

  // Default constructor
  ActivityStateHelper(
      final String CHANNEL,
      final Application application,
      final Activity activity,
      final BinaryMessenger messenger,
      final MethodChannel.MethodCallHandler handler,
      final PluginRegistry.Registrar registrar,
      final ActivityPluginBinding activityBinding) {
    this.application = application;
    this.activity = activity;
    this.activityBinding = activityBinding;

    delegate = constructDelegate(activity);
    channel = new MethodChannel(messenger, CHANNEL);
    channel.setMethodCallHandler(handler);
    observer = new LifeCycleHelper(activity);
    if (registrar != null) {
      // V1 embedding setup for activity listeners.
      application.registerActivityLifecycleCallbacks(observer);
      registrar.addActivityResultListener(delegate);
      registrar.addRequestPermissionsResultListener(delegate);
    } else {
      // V2 embedding setup for activity listeners.
      activityBinding.addActivityResultListener(delegate);
      activityBinding.addRequestPermissionsResultListener(delegate);
      lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(activityBinding);
      lifecycle.addObserver(observer);
    }
  }

  // Only invoked by {@link #FileSelectorPlugin(FileSelectorDelegate, Activity)}
  // for testing.
  ActivityStateHelper(final FileSelectorDelegate delegate, final Activity activity) {
    this.activity = activity;
    this.delegate = delegate;
  }

  void release() {
    if (activityBinding != null) {
      activityBinding.removeActivityResultListener(delegate);
      activityBinding.removeRequestPermissionsResultListener(delegate);
      activityBinding = null;
    }

    if (lifecycle != null) {
      lifecycle.removeObserver(observer);
      lifecycle = null;
    }

    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }

    if (application != null) {
      application.unregisterActivityLifecycleCallbacks(observer);
      application = null;
    }

    activity = null;
    observer = null;
    delegate = null;
  }

  Activity getActivity() {
    return activity;
  }

  FileSelectorDelegate getDelegate() {
    return delegate;
  }

  @VisibleForTesting
  FileSelectorDelegate constructDelegate(final Activity setupActivity) {
    return new FileSelectorDelegate(setupActivity);
  }
}
