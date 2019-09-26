// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class CameraPlugin implements FlutterPlugin, ActivityAware {

  @Nullable
  private FlutterPluginBinding pluginBinding;
  @Nullable
  private ActivityPluginBinding activityBinding;
  @Nullable
  private CameraPluginProtocol cameraPluginProtocol;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = flutterPluginBinding;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    this.activityBinding = activityPluginBinding;
    setup();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    teardown();
    this.activityBinding = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
    this.activityBinding = activityPluginBinding;
    setup();
  }

  @Override
  public void onDetachedFromActivity() {
    teardown();
    this.activityBinding = null;
  }

  private void setup() {
    // Setup
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only. Also, if the sdk is
      // less than 21 (min sdk for Camera2) we don't register the plugin.
      return;
    }

    CameraPermissions cameraPermissions = new AndroidCameraPermissions(activityBinding);
    EventChannel imageStreamChannel = new EventChannel(
        pluginBinding.getFlutterEngine().getDartExecutor(),
        "plugins.flutter.io/camera/imageStream"
    );
    CameraPreviewDisplay cameraImageStream = new CameraPluginProtocol.ChannelCameraPreviewDisplay(imageStreamChannel);
    CameraPluginProtocol.CameraEventChannelFactory cameraChannelFactory = new CameraPluginProtocol.CameraEventChannelFactory() {
      @NonNull
      @Override
      public EventChannel createCameraEventChannel(long textureId) {
        return new EventChannel(
            pluginBinding.getFlutterEngine().getDartExecutor(),
            "flutter.io/cameraPlugin/cameraEvents" + textureId
        );
      }
    };
    CameraSystem cameraSystem = new AndroidCameraSystem(
        pluginBinding,
        activityBinding,
        cameraPermissions,
        cameraImageStream,
        cameraChannelFactory
    );
    this.cameraPluginProtocol = new CameraPluginProtocol(cameraSystem);

    final MethodChannel primaryPluginChannel = new MethodChannel(
        pluginBinding.getFlutterEngine().getDartExecutor(),
        "plugins.flutter.io/camera"
    );
    primaryPluginChannel.setMethodCallHandler(cameraPluginProtocol.getCameraSystemChannelHandler());
  }

  private void teardown() {
    // Teardown
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only. Also, if the sdk is
      // less than 21 (min sdk for Camera2) we don't register the plugin.
      return;
    }

    cameraPluginProtocol.release();
  }
}
