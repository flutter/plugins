package io.flutter.plugins.camera.features.focuspoint;

import android.hardware.camera2.CaptureRequest;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import java.util.concurrent.Callable;

/** Focus point controls where in the frame focus will come from. */
public class FocusPoint implements CameraFeature<Point> {
  // Used later to always get the correct camera regions instance.
  private final Callable<CameraRegions> getCameraRegions;
  private boolean isSupported;
  private Point currentSetting = new Point(0.0, 0.0);

  public FocusPoint(CameraProperties cameraProperties, Callable<CameraRegions> getCameraRegions) {
    this.getCameraRegions = getCameraRegions;
    this.isSupported = checkIsSupported(cameraProperties);
  }

  @Override
  public String getDebugName() {
    return "FocusPoint";
  }

  @Override
  public Point getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Point value) {
    this.currentSetting = value;

    try {
      if (value.x == null || value.y == null) {
        getCameraRegions.call().resetAutoFocusMeteringRectangle();
      } else {
        getCameraRegions.call().setAutoFocusMeteringRectangleFromPoint(value.x, value.y);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // Whether or not this camera can set the exposure point.
  @Override
  public boolean checkIsSupported(CameraProperties cameraProperties) {
    Integer supportedRegions = cameraProperties.getControlMaxRegionsAutoFocus();
    final boolean supported = supportedRegions != null && supportedRegions > 0;
    return supported;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!isSupported) {
      return;
    }
  }

  public boolean getIsSupported() {
    return this.isSupported;
  }
}
