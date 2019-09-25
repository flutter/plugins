// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

import java.util.List;

/* package */ interface CameraSystem {
  List<CameraDetails> getAvailableCameras() throws CameraAccessException;

  void initialize(
      @NonNull CameraConfigurationRequest request,
      @NonNull OnCameraInitializationCallback callback
  );

  void takePicture(
      @NonNull String filePath,
      @NonNull Camera.OnPictureTakenCallback callback
  );

  void startVideoRecording(
      @NonNull String filePath,
      @NonNull OnStartVideoRecordingCallback callback
  );

  void stopVideoRecording(@NonNull OnVideoRecordingCommandCallback callback);

  void pauseVideoRecording(@NonNull OnApiDependentVideoRecordingCommandCallback callback);

  void resumeVideoRecording(@NonNull OnApiDependentVideoRecordingCommandCallback callback);

  void startImageStream(@NonNull OnCameraAccessCommandCallback callback);

  void stopImageStream(@NonNull OnCameraAccessCommandCallback callback);

  void dispose();

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

  /* package */ class CameraConfigurationRequest {
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
