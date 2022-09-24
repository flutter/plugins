// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;

/** Platform implementation of the camera_plugin implemented with the CameraX library. */
public final class CameraAndroidCameraxPlugin implements FlutterPlugin, ActivityAware {
  private InstanceManager instanceManager;
  private FlutterPluginBinding pluginBinding;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code io.flutter.plugins.camera.MainActivity} for an example.
   */
  public CameraAndroidCameraxPlugin() {}

  void setUp(BinaryMessenger binaryMessenger, Context context) {
    // Set up instance manager.
    instanceManager =
        InstanceManager.open(
            identifier -> {
              new GeneratedCameraXLibrary.JavaObjectFlutterApi(binaryMessenger)
                  .dispose(identifier, reply -> {});
            });

    // Set up Host APIs.
    GeneratedCameraXLibrary.CameraInfoHostApi.setup(
        binaryMessenger, new CameraInfoHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.JavaObjectHostApi.setup(
        binaryMessenger, new JavaObjectHostApiImpl(instanceManager));
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    pluginBinding = flutterPluginBinding;
    (new CameraAndroidCameraxPlugin())
        .setUp(
            flutterPluginBinding.getBinaryMessenger(),
            flutterPluginBinding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (instanceManager != null) {
      instanceManager.close();
    }
  }

  // Activity Lifecycle methods:

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {}

  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onReattachedToActivityForConfigChanges(
      @NonNull ActivityPluginBinding activityPluginBinding) {}

  @Override
  public void onDetachedFromActivity() {}
}
