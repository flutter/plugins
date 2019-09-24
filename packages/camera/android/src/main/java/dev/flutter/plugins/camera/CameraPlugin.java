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

public class CameraPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {

  private final CameraPermissions cameraPermissions = new CameraPermissions();
  private EventChannel imageStreamChannel;
  private Camera camera;

  private FlutterPluginBinding pluginBinding;
  private ActivityPluginBinding activityBinding;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = flutterPluginBinding;
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

    this.imageStreamChannel = new EventChannel(
        this.pluginBinding.getFlutterEngine().getDartExecutor(),
        "plugins.flutter.io/camera/imageStream"
    );

    final MethodChannel channel =
        new MethodChannel(pluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/camera");

    channel.setMethodCallHandler(this);
  }

  // TODO: there are 2+ channels
  // 1:EventChannel   - plugins.flutter.io/camera/imageStream
  // 1:MethodChannel  - plugins.flutter.io/camera
  // 0+:EventChannel  - flutter.io/cameraPlugin/cameraEvents[textureId]

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

  private void instantiateCamera(MethodCall call, Result result) throws CameraAccessException {
    String cameraName = call.argument("cameraName");
    String resolutionPreset = call.argument("resolutionPreset");
    boolean enableAudio = call.argument("enableAudio");
    camera = new Camera(
        activityBinding.getActivity(),
        pluginBinding.getFlutterEngine().getRenderer(),
        cameraName,
        resolutionPreset,
        enableAudio
    );

    EventChannel cameraEventChannel =
        new EventChannel(
            pluginBinding.getFlutterEngine().getDartExecutor(),
            "flutter.io/cameraPlugin/cameraEvents" + camera.getFlutterTexture().id());
    camera.setupCameraEventChannel(cameraEventChannel);

    camera.open(result);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    switch (call.method) {
      case "availableCameras":
        try {
          result.success(CameraUtils.getAvailableCameras(activityBinding.getActivity()));
        } catch (Exception e) {
          handleException(e, result);
        }
        break;
      case "initialize":
        {
          if (camera != null) {
            camera.close();
          }
          cameraPermissions.requestPermissions(
              activityBinding,
              call.argument("enableAudio"),
              (String errCode, String errDesc) -> {
                if (errCode == null) {
                  try {
                    instantiateCamera(call, result);
                  } catch (Exception e) {
                    handleException(e, result);
                  }
                } else {
                  result.error(errCode, errDesc, null);
                }
              });

          break;
        }
      case "takePicture":
        {
          camera.takePicture(call.argument("path"), result);
          break;
        }
      case "prepareForVideoRecording":
        {
          // This optimization is not required for Android.
          result.success(null);
          break;
        }
      case "startVideoRecording":
        {
          camera.startVideoRecording(call.argument("filePath"), result);
          break;
        }
      case "stopVideoRecording":
        {
          camera.stopVideoRecording(result);
          break;
        }
      case "pauseVideoRecording":
        {
          camera.pauseVideoRecording(result);
          break;
        }
      case "resumeVideoRecording":
        {
          camera.resumeVideoRecording(result);
          break;
        }
      case "startImageStream":
        {
          try {
            CameraPreviewDisplay previewDisplay = new CameraPreviewDisplay(imageStreamChannel);
            camera.startPreviewWithImageStream(previewDisplay);
            result.success(null);
          } catch (Exception e) {
            handleException(e, result);
          }
          break;
        }
      case "stopImageStream":
        {
          try {
            camera.startPreview();
            result.success(null);
          } catch (Exception e) {
            handleException(e, result);
          }
          break;
        }
      case "dispose":
        {
          if (camera != null) {
            camera.dispose();
          }
          result.success(null);
          break;
        }
      default:
        result.notImplemented();
        break;
    }
  }

  // We move catching CameraAccessException out of onMethodCall because it causes a crash
  // on plugin registration for sdks incompatible with Camera2 (< 21). We want this plugin to
  // to be able to compile with <21 sdks for apps that want the camera and support earlier version.
  @SuppressWarnings("ConstantConditions")
  private void handleException(Exception exception, Result result) {
    if (exception instanceof CameraAccessException) {
      result.error("CameraAccess", exception.getMessage(), null);
    }

    throw (RuntimeException) exception;
  }
}
