// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.exposureoffset;

import android.hardware.camera2.CaptureRequest;
import android.util.Range;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/** Exposure offset makes the image brighter or darker. */
public class ExposureOffsetFeature extends CameraFeature<ExposureOffsetValue> {
  private ExposureOffsetValue currentSetting;
  private final double min;
  private final double max;

  public ExposureOffsetFeature(CameraProperties cameraProperties) {
    super(cameraProperties);

    this.min = getMinExposureOffset();
    this.max = getMaxExposureOffset();

    // Initial offset of 0
    this.currentSetting = new ExposureOffsetValue(this.min, this.max, 0);
  }

  @Override
  public String getDebugName() {
    return "ExposureOffsetFeature";
  }

  @Override
  public ExposureOffsetValue getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(ExposureOffsetValue value) {
    double stepSize = getExposureOffsetStepSize();
    this.currentSetting = new ExposureOffsetValue(min, max, (value.value / stepSize));
  }

  // Available on all devices.
  @Override
  public boolean checkIsSupported() {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }

    requestBuilder.set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, (int) currentSetting.value);
  }

  /**
   * Return the minimum exposure offset double value.
   *
   * @return
   */
  private double getMinExposureOffset() {
    Range<Integer> range = cameraProperties.getControlAutoExposureCompensationRange();
    double minStepped = range == null ? 0 : range.getLower();
    double stepSize = getExposureOffsetStepSize();
    return minStepped * stepSize;
  }

  /**
   * Return the max exposure offset double value.
   *
   * @return
   */
  private double getMaxExposureOffset() {
    Range<Integer> range = cameraProperties.getControlAutoExposureCompensationRange();
    double maxStepped = range == null ? 0 : range.getUpper();
    double stepSize = getExposureOffsetStepSize();
    return maxStepped * stepSize;
  }

  /**
   * Returns the exposure offset step size. This is the smallest amount which the exposure offset
   * can be changed.
   *
   * <p>Example: if this has a value of 0.5, then an aeExposureCompensation setting of -2 means that
   * the actual AE offset is -1.
   *
   * @return
   */
  public double getExposureOffsetStepSize() {
    return cameraProperties.getControlAutoExposureCompensationStep();
  }
}
