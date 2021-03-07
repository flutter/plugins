package io.flutter.plugins.camera.features.exposureoffset;

import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import android.util.Range;
import android.util.Rational;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/** Exposure offset makes the image brighter or darker. */
public class ExposureOffset implements CameraFeature<ExposureOffsetValue> {
  private boolean isSupported;
  private ExposureOffsetValue currentSetting;
  private CameraProperties cameraProperties;
  private final double min;
  private final double max;

  public ExposureOffset(CameraProperties cameraProperties) {
    this.cameraProperties = cameraProperties;
    this.min = getMinExposureOffset(cameraProperties);
    this.max = getMaxExposureOffset(cameraProperties);

    // Initial offset of 0
    this.currentSetting = new ExposureOffsetValue(this.min, this.max, 0);
  }

  @Override
  public ExposureOffsetValue getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(ExposureOffsetValue value) {
    double stepSize = getExposureOffsetStepSize(cameraProperties);
    this.currentSetting = new ExposureOffsetValue(min, max, (value.value / stepSize));
  }

  // Available on all devices.
  @Override
  public boolean isSupported(CameraProperties cameraProperties) {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    Log.i("Camera", "updateExposureOffset");

    // Don't try to set if the current camera doesn't support it.
    if (!isSupported) {
      return;
    }

    requestBuilder.set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, (int) currentSetting.value);
  }

  /**
   * Return the minimum exposure offset double value.
   *
   * @param cameraProperties
   * @return
   */
  private double getMinExposureOffset(CameraProperties cameraProperties) {
    Range<Integer> range = cameraProperties.getControlAutoExposureCompensationRange();
    double minStepped = range == null ? 0 : range.getLower();
    double stepSize = getExposureOffsetStepSize(cameraProperties);
    return minStepped * stepSize;
  }

  /**
   * Return the max exposure offset double value.
   *
   * @param cameraProperties
   * @return
   */
  private double getMaxExposureOffset(CameraProperties cameraProperties) {
    Range<Integer> range = cameraProperties.getControlAutoExposureCompensationRange();
    double maxStepped = range == null ? 0 : range.getUpper();
    double stepSize = getExposureOffsetStepSize(cameraProperties);
    return maxStepped * stepSize;
  }

  /**
   * Returns the exposure offset step size. This is the smallest amount which the exposure offset
   * can be changed.
   *
   * <p>Example: if this has a value of 0.5, then an aeExposureCompensation setting of -2 means that
   * the actual AE offset is -1.
   *
   * @param cameraProperties
   * @return
   */
  public double getExposureOffsetStepSize(CameraProperties cameraProperties) {
    Rational stepSize = cameraProperties.getControlAutoExposureCompensationStep();
    return stepSize == null ? 0.0 : stepSize.doubleValue();
  }
}
