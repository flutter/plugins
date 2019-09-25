// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/* package */ class CameraPluginProtocol {

  @NonNull
  private CameraSystem cameraSystem;
  @NonNull
  private final CameraSystemChannelHandler channelHandler;

  /* package */ CameraPluginProtocol(@NonNull CameraSystem cameraSystem) {
    this.cameraSystem = cameraSystem;
    this.channelHandler = new CameraSystemChannelHandler(cameraSystem);
  }

  public void release() {
    cameraSystem.dispose();
  }

  @NonNull
  public MethodChannel.MethodCallHandler getCameraSystemChannelHandler() {
    return channelHandler;
  }

  private static class CameraSystemChannelHandler implements MethodChannel.MethodCallHandler {
    @NonNull
    private final CameraSystem cameraSystem;

    CameraSystemChannelHandler(@NonNull CameraSystem cameraSystem) {
      this.cameraSystem = cameraSystem;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
      switch (call.method) {
        case "availableCameras":
          try {
            List<CameraDetails> allCameraDetails = cameraSystem.getAvailableCameras();

            List<Map<String, Object>> allCameraDetailsSerialized = new ArrayList<>();
            for (CameraDetails cameraDetails : allCameraDetails) {
              Map<String, Object> serializedDetails = new HashMap<>();
              serializedDetails.put("name", cameraDetails.getName());
              serializedDetails.put("sensorOrientation", cameraDetails.getSensorOrientation());
              serializedDetails.put("lensDirection", cameraDetails.getLensDirection());
              allCameraDetailsSerialized.add(serializedDetails);
            }

            result.success(allCameraDetailsSerialized);
          } catch (Exception e) {
            handleException(e, result);
          }
          break;
        case "initialize":
        {
          CameraSystem.CameraConfigurationRequest request = new CameraSystem.CameraConfigurationRequest(
              call.argument("cameraName"),
              call.argument("resolutionPreset"),
              call.argument("enableAudio")
          );

          cameraSystem.initialize(request, new CameraSystem.OnCameraInitializationCallback() {
            @Override
            public void onCameraPermissionError(@NonNull String errorCode, @NonNull String description) {
              result.error(errorCode, description, null);
            }

            @Override
            public void onSuccess(long textureId, int previewWidth, int previewHeight) {
              Map<String, Object> reply = new HashMap<>();
              reply.put("textureId", textureId);
              reply.put("previewWidth", previewWidth);
              reply.put("previewHeight", previewHeight);
              result.success(reply);
            }

            @Override
            public void onError(@NonNull String errorCode, @NonNull String description) {
              result.error(errorCode, description, null);
            }
          });
          break;
        }
        case "takePicture":
        {
          final String filePath = call.argument("path");
          cameraSystem.takePicture(filePath, new Camera.OnPictureTakenCallback() {
            @Override
            public void onPictureTaken() {
              result.success(null);
            }

            @Override
            public void onFileAlreadyExists() {
              result.error(
                  "fileExists",
                  "File at path '" + filePath + "' already exists. Cannot overwrite.",
                  null
              );
            }

            @Override
            public void onFailedToSaveImage() {
              result.error("IOError", "Failed saving image", null);
            }

            @Override
            public void onCaptureFailure(@NonNull String reason) {
              result.error("captureFailure", reason, null);
            }

            @Override
            public void onCameraAccessFailure(@NonNull String message) {
              result.error("cameraAccess", message, null);
            }
          });
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
          String filePath = call.argument("filePath");
          cameraSystem.startVideoRecording(filePath, new CameraSystem.OnStartVideoRecordingCallback() {
            @Override
            public void onSuccess() {
              result.success(null);
            }

            @Override
            public void onFileAlreadyExists(@NonNull String filePath) {
              result.error("fileExists", "File at path '" + filePath + "' already exists.", null);
            }

            @Override
            public void onVideoRecordingFailed(@NonNull String message) {
              result.error("videoRecordingFailed", message, null);
            }
          });
          break;
        }
        case "stopVideoRecording":
        {
          cameraSystem.stopVideoRecording(new CameraSystem.OnVideoRecordingCommandCallback() {
            @Override
            public void onSuccess() {
              result.success(null);
            }

            @Override
            public void onVideoRecordingFailed(@NonNull String message) {
              result.error("videoRecordingFailed", message, null);
            }
          });
          break;
        }
        case "pauseVideoRecording":
        {
          cameraSystem.pauseVideoRecording(new CameraSystem.OnApiDependentVideoRecordingCommandCallback() {
            @Override
            public void onSuccess() {
              result.success(null);
            }

            @Override
            public void onUnsupportedOperation() {
              result.error("videoRecordingFailed", "pauseVideoRecording requires Android API +24.", null);
            }

            @Override
            public void onVideoRecordingFailed(@NonNull String message) {
              result.error("videoRecordingFailed", message, null);
            }
          });
          break;
        }
        case "resumeVideoRecording":
        {
          cameraSystem.resumeVideoRecording(new CameraSystem.OnApiDependentVideoRecordingCommandCallback() {
            @Override
            public void onSuccess() {
              result.success(null);
            }

            @Override
            public void onUnsupportedOperation() {
              result.error("videoRecordingFailed","resumeVideoRecording requires Android API +24.",null);
            }

            @Override
            public void onVideoRecordingFailed(@NonNull String message) {
              result.error("videoRecordingFailed", message, null);
            }
          });
          break;
        }
        case "startImageStream":
        {
          cameraSystem.startImageStream(new CameraSystem.OnCameraAccessCommandCallback() {
            @Override
            public void success() {
              result.success(null);
            }

            @Override
            public void onCameraAccessFailure(@NonNull String message) {
              result.error("CameraAccess", message, null);
            }
          });
          break;
        }
        case "stopImageStream":
        {
          cameraSystem.stopImageStream(new CameraSystem.OnCameraAccessCommandCallback() {
            @Override
            public void success() {
              result.success(null);
            }

            @Override
            public void onCameraAccessFailure(@NonNull String message) {
              result.error("CameraAccess", message, null);
            }
          });
          break;
        }
        case "dispose":
        {
          cameraSystem.dispose();
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
    private void handleException(Exception exception, MethodChannel.Result result) {
      if (exception instanceof CameraAccessException) {
        result.error("CameraAccess", exception.getMessage(), null);
      }

      throw (RuntimeException) exception;
    }
  }

}
