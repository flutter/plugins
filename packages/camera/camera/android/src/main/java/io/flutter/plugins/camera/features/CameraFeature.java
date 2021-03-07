package io.flutter.plugins.camera.features;

import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;

/**
 * An interface describing a feature in the camera. This holds a setting value of type T and must
 * implement a means to check if this setting is supported by the current camera properties. It also
 * must implement a builder update method which will update a given capture request builder for this
 * feature's current setting value.
 *
 * @param <T>
 */
public interface CameraFeature<T> {
  /** Debug name for this feature. */
  public String getDebugName();

  /**
   * Get the current value of this feature's setting.
   *
   * @return
   */
  public T getValue();

  /**
   * Set a new value for this feature's setting.
   *
   * @param value
   */
  public void setValue(T value);

  /**
   * Returns whether or not this feature is supported on the given camera properties.
   *
   * @return
   */
  public boolean checkIsSupported(CameraProperties cameraProperties);

  /**
   * Update the setting in a provided request builder.
   *
   * @param requestBuilder
   */
  public void updateBuilder(CaptureRequest.Builder requestBuilder);
}
