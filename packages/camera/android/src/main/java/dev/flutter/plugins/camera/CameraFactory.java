package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

/**
 * Produces {@link Camera} instances when requested.
 *
 * <p>This factory exists to separate the dependencies required to create a {@link Camera}
 * from the need to be able to create {@link Camera}s, which is useful from a testing standpoint.
 */
public interface CameraFactory {
  @NonNull
  Camera createCamera(
      @NonNull String cameraName,
      @NonNull String resolutionPreset,
      boolean enableAudio
  ) throws CameraAccessException;
}
