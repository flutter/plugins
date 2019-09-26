// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.IOException;
import java.util.List;

import io.flutter.plugin.common.EventChannel;

/**
 * Top-level facade for all Camera plugin behavior.
 *
 * <p>The public interface of this class is purposefully established as close to a 1:1 relationship
 * with the plugin's channel communication as possible, representing a channel-agnostic implementation
 * of the plugin.
 *
 * <p>This class avoids Android implementation details, by design. It allows tests to verify
 * top-level behavior expectations with JVM tests. All of {@code CameraSystem}'s conceptual
 * dependencies are modeled with interfaces, or classes that can be easily mocked.
 */
/* package */ class CameraSystem {
  @NonNull
  private final CameraPermissions cameraPermissions;
  @NonNull
  private final CameraHardware cameraHardware;
  @NonNull
  private final CameraPreviewDisplay cameraPreviewDisplay;
  @NonNull
  private final CameraPluginProtocol.CameraEventChannelFactory cameraEventChannelFactory;
  @NonNull
  private final CameraFactory cameraFactory;
  @Nullable
  private Camera camera;

  /* package */ CameraSystem(
      @NonNull CameraPermissions cameraPermissions,
      @NonNull CameraHardware cameraHardware,
      @NonNull CameraPreviewDisplay cameraPreviewDisplay,
      @NonNull CameraPluginProtocol.CameraEventChannelFactory cameraEventChannelFactory,
      @NonNull CameraFactory cameraFactory
  ) {
    this.cameraPermissions = cameraPermissions;
    this.cameraHardware = cameraHardware;
    this.cameraPreviewDisplay = cameraPreviewDisplay;
    this.cameraEventChannelFactory = cameraEventChannelFactory;
    this.cameraFactory = cameraFactory;
  }

  public List<CameraDetails> getAvailableCameras() throws CameraAccessException {
    return cameraHardware.getAvailableCameras();
  }

  public void initialize(
      @NonNull CameraConfigurationRequest request,
      @NonNull OnCameraInitializationCallback callback
  ) {
    if (camera != null) {
      camera.close();
    }

    if (!cameraPermissions.hasCameraPermission() || (request.getEnableAudio() ))

      cameraPermissions.requestPermissions(
          request.getEnableAudio(),
          new CameraPermissions.ResultCallback() {
            @Override
            public void onSuccess() {
              try {
                openCamera(request, callback);
              } catch (Exception error) {
                callback.onError("CameraAccess", error.getMessage());
              }
            }

            @Override
            public void onResult(String errorCode, String errorDescription) {
              callback.onCameraPermissionError(errorCode, errorDescription);
            }
          });
  }

  private void openCamera(
      @NonNull CameraConfigurationRequest request,
      @NonNull OnCameraInitializationCallback callback
  ) throws CameraAccessException {
    camera = cameraFactory.createCamera(
        request.getCameraName(),
        request.getResolutionPreset(),
        request.getEnableAudio()
    );

    camera.open(new Camera.OnCameraOpenedCallback() {
      @Override
      public void onCameraOpened(long textureId, int previewWidth, int previewHeight) {
        callback.onSuccess(textureId, previewWidth, previewHeight);
      }

      @Override
      public void onCameraOpenFailed(@NonNull String message) {
        callback.onError("CameraAccess", message);
      }
    });

    final CameraPluginProtocol.ChannelCameraEventHandler eventHandler = new CameraPluginProtocol.ChannelCameraEventHandler();
    camera.setCameraEventHandler(eventHandler);

    EventChannel cameraEventChannel = cameraEventChannelFactory.createCameraEventChannel(camera.getTextureId());
    cameraEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object o, final EventChannel.EventSink eventSink) {
        eventHandler.setEventSink(eventSink);
      }

      @Override
      public void onCancel(Object o) {
        eventHandler.setEventSink(null);
      }
    });
  }

  public void takePicture(@NonNull String filePath, @NonNull Camera.OnPictureTakenCallback callback) {
    // TODO(mattcarroll): determine desired behavior when no camera is active
    camera.takePicture(filePath, callback);
  }

  public void startVideoRecording(@NonNull String filePath, @NonNull OnStartVideoRecordingCallback callback) {
    // TODO(mattcarroll): determine desired behavior when no camera is active
    try {
      camera.startVideoRecording(filePath);
    } catch (IllegalStateException e) {
      callback.onFileAlreadyExists(filePath);
    } catch (CameraAccessException | IOException e) {
      callback.onVideoRecordingFailed(e.getMessage());
    }
  }

  public void stopVideoRecording(@NonNull OnVideoRecordingCommandCallback callback) {
    // TODO(mattcarroll): determine desired behavior when no camera is active
    try {
      camera.stopVideoRecording();
      callback.success();
    } catch (CameraAccessException | IllegalStateException e) {
      callback.onVideoRecordingFailed(e.getMessage());
    }
  }

  public void pauseVideoRecording(@NonNull OnApiDependentVideoRecordingCommandCallback callback) {
    // TODO(mattcarroll): determine desired behavior when no camera is active
    try {
      camera.pauseVideoRecording();
    } catch (UnsupportedOperationException e) {
      callback.onUnsupportedOperation();
    } catch (IllegalStateException e) {
      callback.onVideoRecordingFailed(e.getMessage());
    }
  }

  public void resumeVideoRecording(@NonNull OnApiDependentVideoRecordingCommandCallback callback) {
    // TODO(mattcarroll): determine desired behavior when no camera is active
    try {
      camera.resumeVideoRecording();
    } catch (UnsupportedOperationException e) {
      callback.onUnsupportedOperation();
    } catch (IllegalStateException e) {
      callback.onVideoRecordingFailed(e.getMessage());
    }
  }

  public void startImageStream(@NonNull OnCameraAccessCommandCallback callback) {
    // TODO(mattcarroll): determine desired behavior when no camera is active
    try {
      camera.startPreviewWithImageStream(cameraPreviewDisplay);
      callback.success();
    } catch (CameraAccessException e) {
      callback.onCameraAccessFailure(e.getMessage());
    }
  }

  public void stopImageStream(@NonNull OnCameraAccessCommandCallback callback) {
    // TODO(mattcarroll): determine desired behavior when no camera is active
    try {
      camera.startPreview();
      callback.success();
    } catch (CameraAccessException e) {
      callback.onCameraAccessFailure(e.getMessage());
    }
  }

  public void dispose() {
    if (camera != null) {
      camera.dispose();
    }
  }

  /* package */ interface OnCameraInitializationCallback {
    void onCameraPermissionError(@NonNull String errorCode, @NonNull String description);

    void onSuccess(long textureId, int previewWidth, int previewHeight);

    void onError(@NonNull String errorCode, @NonNull String description);
  }

  /* package */ interface OnVideoRecordingCommandCallback {
    void success();

    void onVideoRecordingFailed(@NonNull String message);
  }

  /* package */ interface OnStartVideoRecordingCallback extends OnVideoRecordingCommandCallback {
    void onFileAlreadyExists(@NonNull String filePath);
  }

  /* package */ interface OnApiDependentVideoRecordingCommandCallback extends OnVideoRecordingCommandCallback {
    void onUnsupportedOperation();
  }

  /* package */ interface OnCameraAccessCommandCallback {
    void success();

    void onCameraAccessFailure(@NonNull String message);
  }

  /* package */ static class CameraConfigurationRequest {
    @NonNull
    private final String cameraName;
    @NonNull
    private final String resolutionPreset;
    @NonNull
    private final boolean enableAudio;

    /* package */ CameraConfigurationRequest(
        @NonNull String cameraName,
        @NonNull String resolutionPreset,
        @NonNull boolean enableAudio
    ) {
      this.cameraName = cameraName;
      this.resolutionPreset = resolutionPreset;
      this.enableAudio = enableAudio;
    }

    @NonNull
    public String getCameraName() {
      return cameraName;
    }

    @NonNull
    public String getResolutionPreset() {
      return resolutionPreset;
    }

    public boolean getEnableAudio() {
      return enableAudio;
    }

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;

      CameraConfigurationRequest that = (CameraConfigurationRequest) o;

      if (enableAudio != that.enableAudio) return false;
      if (!cameraName.equals(that.cameraName)) return false;
      return resolutionPreset.equals(that.resolutionPreset);
    }

    @Override
    public int hashCode() {
      int result = cameraName.hashCode();
      result = 31 * result + resolutionPreset.hashCode();
      result = 31 * result + (enableAudio ? 1 : 0);
      return result;
    }
  }
}
