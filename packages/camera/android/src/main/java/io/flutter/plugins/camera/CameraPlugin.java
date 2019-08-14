// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;

public class CameraPlugin implements MethodCallHandler {

  private final CameraPermissions cameraPermissions = new CameraPermissions();
  private final FlutterView view;
  private final Registrar registrar;
  private final EventChannel imageStreamChannel;
  private Camera camera;

  private CameraPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.view = registrar.view();
    this.imageStreamChannel =
        new EventChannel(registrar.messenger(), "plugins.flutter.io/camera/imageStream");
  }

  public static void registerWith(Registrar registrar) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only. Also, if the sdk is
      // less than 21 (min sdk for Camera2) we don't register the plugin.
      return;
    }

    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/camera");

    channel.setMethodCallHandler(new CameraPlugin(registrar));
  }

  private void instantiateCamera(MethodCall call, Result result) throws CameraAccessException {
    String cameraName = call.argument("cameraName");
    String resolutionPreset = call.argument("resolutionPreset");
    boolean enableAudio = call.argument("enableAudio");
    camera = new Camera(registrar.activity(), view, cameraName, resolutionPreset, enableAudio);

    EventChannel cameraEventChannel =
        new EventChannel(
            registrar.messenger(),
            "flutter.io/cameraPlugin/cameraEvents" + camera.getFlutterTexture().id());
    camera.setupCameraEventChannel(cameraEventChannel);

    camera.open(result);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    switch (call.method) {
      case "availableCameras":
        try {
          result.success(CameraUtils.getAvailableCameras(registrar.activity()));
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
              registrar,
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
      case "startImageStream":
        {
          try {
            camera.startPreviewWithImageStream(imageStreamChannel);
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
