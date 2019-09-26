package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

public interface CameraFactory {
  @NonNull
  Camera createCamera(
      @NonNull String cameraName,
      @NonNull String resolutionPreset,
      boolean enableAudio
  ) throws CameraAccessException;
}
