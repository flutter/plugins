// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector;

import android.app.Activity;
import android.app.Application;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.file_selector.Messages.FileSelectorApi;
import java.util.List;

/** Android platform implementation of the FileSelectorPlugin. */
public class FileSelectorPlugin implements FlutterPlugin, FileSelectorApi, ActivityAware {

  static final String TAG = "FileSelectorPlugin";

  FlutterPluginBinding pluginBinding;
  ActivityStateHelper activityState;
  FileSelectorDelegate delegate;

  /**
   * Default constructor for the plugin.
   *
   * <p>Use this constructor for production code.
   */
  public FileSelectorPlugin() {}

  @VisibleForTesting
  FileSelectorPlugin(final FileSelectorDelegate delegate, final Activity activity) {
    activityState = new ActivityStateHelper(delegate, activity);
  }

  final ActivityStateHelper getActivityState() {
    return activityState;
  }

  private void setup(
      BinaryMessenger messenger,
      final Application application,
      final Activity activity,
      final ActivityPluginBinding activityBinding) {

    try {
      FileSelectorApi.setup(messenger, this);
      activityState = new ActivityStateHelper(application, activity, activityBinding);
    } catch (Exception ex) {
      Log.e(TAG, "Received exception while setting up PathProviderPlugin", ex);
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    setup(
        pluginBinding.getBinaryMessenger(),
        (Application) pluginBinding.getApplicationContext(),
        binding.getActivity(),
        binding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  @VisibleForTesting
  void tearDown() {
    if (activityState != null) {
      activityState.release();
      activityState = null;
      if (delegate != null) {
        delegate.clearCache();
      }
    }
  }

  @Override
  public void openFiles(
      @NonNull Messages.SelectionOptions options, Messages.Result<List<String>> result) {
    if (activityState == null || activityState.getActivity() == null) {
      result.error(new Throwable("file_selector plugin requires a foreground activity.", null));
    }

    delegate = activityState.getDelegate();

    delegate.openFile(options, result);
  }

  @Override
  public void getDirectoryPath(@Nullable String initialDirectory, Messages.Result<String> result) {
    if (activityState == null || activityState.getActivity() == null) {
      result.error(new Throwable("file_selector plugin requires a foreground activity.", null));
    }

    delegate = activityState.getDelegate();

    delegate.getDirectoryPath(initialDirectory, result);
  }
}
