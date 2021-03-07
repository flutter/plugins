package io.flutter.plugins.camera.features.regionboundaries;

import android.annotation.TargetApi;
import android.hardware.camera2.CaptureRequest;
import android.os.Build;
import android.util.Size;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;
import java.util.Arrays;

/**
 * Holds the current region boundaries. When this is created, you must provide a
 * CaptureRequestBuilder for which we can read the distortion correction settings from.
 */
public class RegionBoundaries implements CameraFeature<Size> {
  private boolean isSupported;
  private Size currentSetting;
  private CameraProperties cameraProperties;
  private CameraRegions cameraRegions;

  public RegionBoundaries(
      CameraProperties cameraProperties, CaptureRequest.Builder requestBuilder) {
    this.cameraProperties = cameraProperties;
    // No distortion correction support
    if (android.os.Build.VERSION.SDK_INT < Build.VERSION_CODES.P
        || !supportsDistortionCorrection()) {
      setValue(cameraProperties.getSensorInfoPixelArraySize());
    }

    // Get the current distortion correction mode
    Integer distortionCorrectionMode = null;
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
      distortionCorrectionMode = requestBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE);
    }

    // Return the correct boundaries depending on the mode
    android.graphics.Rect rect;
    if (distortionCorrectionMode == null
        || distortionCorrectionMode == CaptureRequest.DISTORTION_CORRECTION_MODE_OFF) {
      rect = cameraProperties.getSensorInfoPreCorrectionActiveArraySize();
    } else {
      rect = cameraProperties.getSensorInfoActiveArraySize();
    }

    // Set new region size
    setValue(rect == null ? null : new Size(rect.width(), rect.height()));

    // Create new camera regions using new size
    cameraRegions = new CameraRegions(currentSetting);
  }

  @Override
  public Size getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Size value) {
    this.currentSetting = value;
  }

  // Available on all devices.
  @Override
  public boolean isSupported(CameraProperties cameraProperties) {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!isSupported) {
      return;
    }
  }

  @TargetApi(Build.VERSION_CODES.P)
  private boolean supportsDistortionCorrection() {
    int[] availableDistortionCorrectionModes =
        cameraProperties.getDistortionCorrectionAvailableModes();
    if (availableDistortionCorrectionModes == null) availableDistortionCorrectionModes = new int[0];
    long nonOffModesSupported =
        Arrays.stream(availableDistortionCorrectionModes)
            .filter((value) -> value != CaptureRequest.DISTORTION_CORRECTION_MODE_OFF)
            .count();
    return nonOffModesSupported > 0;
  }

  public CameraRegions getCameraRegions() {
    return this.cameraRegions;
  }
}
