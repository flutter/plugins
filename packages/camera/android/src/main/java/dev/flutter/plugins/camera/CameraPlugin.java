// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;
import android.os.Build;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.camera.Camera;
import io.flutter.plugins.camera.CameraChannelHandler;
import io.flutter.plugins.camera.CameraPermissions;
import io.flutter.plugins.camera.CameraUtils;

public class CameraPlugin implements FlutterPlugin, ActivityAware {

  private FlutterPluginBinding pluginBinding;
  private ActivityPluginBinding activityBinding;

  private final CameraPermissions cameraPermissions = new CameraPermissions();
  private EventChannel imageStreamChannel;
  private Camera camera;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = flutterPluginBinding;
    this.imageStreamChannel = new EventChannel(
        this.pluginBinding.getFlutterEngine().getDartExecutor(),
        "plugins.flutter.io/camera/imageStream"
    );
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    // Setup
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only. Also, if the sdk is
      // less than 21 (min sdk for Camera2) we don't register the plugin.
      return;
    }

    this.activityBinding = activityPluginBinding;

    final MethodChannel channel =
        new MethodChannel(pluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/camera");

    channel.setMethodCallHandler(new CameraChannelHandler(
        activityPluginBinding.getActivity(),
        pluginBinding.getFlutterEngine().getRenderer(),
        pluginBinding.getFlutterEngine().getDartExecutor(),
        new EventChannel(pluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/camera/imageStream"),
        new NewEmbeddingPermissions(activityPluginBinding)
    ));
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    // Ignore
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    // Ignore
  }

  @Override
  public void onDetachedFromActivity() {
    // Teardown
    this.activityBinding = null;
  }

  private static class NewEmbeddingPermissions implements CameraPermissions.Permissions {
    private ActivityPluginBinding activityPluginBinding;

    private NewEmbeddingPermissions(@NonNull ActivityPluginBinding activityPluginBinding) {
      this.activityPluginBinding = activityPluginBinding;
    }

    @Override
    public PluginRegistry.Registrar addRequestPermissionsResultListener(PluginRegistry.RequestPermissionsResultListener listener) {
      activityPluginBinding.addRequestPermissionsResultListener(listener);

      return null; // <- this is a breaking change.
    }
  }
}
