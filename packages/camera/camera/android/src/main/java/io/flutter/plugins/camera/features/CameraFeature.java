// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features;

import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.CameraProperties;

/**
 * An interface describing a feature in the camera. This holds a setting value of type T and must
 * implement a means to check if this setting is supported by the current camera properties. It also
 * must implement a builder update method which will update a given capture request builder for this
 * feature's current setting value.
 *
 * @param <T>
 */
public abstract class CameraFeature<T> {
  protected final CameraProperties cameraProperties;


  protected CameraFeature(@NonNull CameraProperties cameraProperties) {
    this.cameraProperties = cameraProperties;
  }

  /** Debug name for this feature. */
  public abstract String getDebugName();

  /**
   * Get the current value of this feature's setting.
   *
   * @return
   */
  public abstract T getValue();

  /**
   * Set a new value for this feature's setting.
   *
   * @param value
   */
  public abstract void setValue(T value);

  /**
   * Returns whether or not this feature is supported.
   *
   * @return
   */
  public abstract boolean checkIsSupported();

  /**
   * Update the setting in a provided request builder.
   *
   * @param requestBuilder
   */
  public abstract void updateBuilder(CaptureRequest.Builder requestBuilder);
}
