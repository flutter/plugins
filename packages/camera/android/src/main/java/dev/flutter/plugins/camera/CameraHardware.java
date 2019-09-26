package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

import java.util.List;

/**
 * Represents a device with cameras and provides relevant queries.
 *
 * <p>This concept is separated from its implementation so that other objects can express a
 * dependency on these queries, regardless of how these queries are implemented, which is useful
 * for testing.
 */
public interface CameraHardware {
  @NonNull
  List<CameraDetails> getAvailableCameras() throws CameraAccessException;
}
