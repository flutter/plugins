package io.flutter.plugins.camera.features.exposurelock;

import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/**
 * Exposure lock controls whether or not exposure mode is currenty locked or automatically metering.
 */
public class ExposureLock implements CameraFeature<ExposureMode> {
  private boolean isSupported;
  private ExposureMode currentSetting = ExposureMode.auto;

  public ExposureLock(CameraProperties cameraProperties) {
    this.isSupported = checkIsSupported(cameraProperties);
  }

  @Override
  public String getDebugName() {
    return "ExposureLock";
  }

  @Override
  public ExposureMode getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(ExposureMode value) {
    this.currentSetting = value;
  }

  // Available on all devices.
  @Override
  public boolean checkIsSupported(CameraProperties cameraProperties) {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!isSupported) {
      return;
    }

    Log.i("Camera", "updateExposureLock | currentSetting: " + currentSetting);

    switch (currentSetting) {
      case locked:
        requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, true);
        break;
      case auto:
      default:
        requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        break;
    }
  }

  public boolean getIsSupported() {
    return this.isSupported;
  }
}
