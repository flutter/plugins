// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;


import androidx.annotation.Nullable;

public class CameraCaptureProperties {

  public static interface Callback {
    void onChanged();
  }

  private Float lastLensAperture;
  private Long lastSensorExposureTime;
  private Integer lastSensorSensitivity;
  private Callback callback;

  /**
   * Gets the last known lens aperture. (As f-stop value)
   *
   * @return the last known lens aperture. (As f-stop value)
   */
  public Float getLastLensAperture() {
    return lastLensAperture;
  }

  /**
   * Sets the last known lens aperture. (As f-stop value)
   *
   * @param lastLensAperture - The last known lens aperture to set. (As f-stop value)
   */
  public void setLastLensAperture(Float lastLensAperture) {
    this.lastLensAperture = lastLensAperture;
  }

  /**
   * Gets the last known sensor exposure time in nanoseconds.
   *
   * @return the last known sensor exposure time in nanoseconds.
   */
  public Long getLastSensorExposureTime() {
    return lastSensorExposureTime;
  }

  /**
   * Sets the last known sensor exposure time in nanoseconds.
   *
   * @param lastSensorExposureTime - The last known sensor exposure time to set, in nanoseconds.
   */
  public void setLastSensorExposureTime(Long lastSensorExposureTime) {
    this.lastSensorExposureTime = lastSensorExposureTime;
    if (callback != null) callback.onChanged();
  }

  /**
   * Gets the last known sensor sensitivity in ISO arithmetic units.
   *
   * @return the last known sensor sensitivity in ISO arithmetic units.
   */
  public Integer getLastSensorSensitivity() {
    return lastSensorSensitivity;
  }

  /**
   * Sets the last known sensor sensitivity in ISO arithmetic units.
   *
   * @param lastSensorSensitivity - The last known sensor sensitivity to set, in ISO arithmetic
   *     units.
   */
  public void setLastSensorSensitivity(Integer lastSensorSensitivity) {
    this.lastSensorSensitivity = lastSensorSensitivity;
    if (callback != null) callback.onChanged();
  }

  public void setCallback(@Nullable Callback callback) {
    this.callback = callback;
  }
}
