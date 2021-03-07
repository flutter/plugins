package io.flutter.plugins.camera.features.exposurepoint;

import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Log;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import java.util.concurrent.Callable;

/** Exposure point controls where in the frame exposure metering will come from. */
public class ExposurePoint implements CameraFeature<Point> {
  // Used later to always get the correct camera regions instance.
  private final Callable<CameraRegions> getCameraRegions;
  private boolean isSupported;
  private Point currentSetting = new Point(0.0, 0.0);

  public ExposurePoint(
      CameraProperties cameraProperties, Callable<CameraRegions> getCameraRegions) {
    this.getCameraRegions = getCameraRegions;
    this.isSupported = checkIsSupported(cameraProperties);
  }

  @Override
  public String getDebugName() {
    return "ExposurePoint";
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
        getCameraRegions.call().resetAutoExposureMeteringRectangle();
      } else {
        getCameraRegions.call().setAutoExposureMeteringRectangleFromPoint(value.x, value.y);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // Whether or not this camera can set the exposure point.
  @Override
  public boolean checkIsSupported(CameraProperties cameraProperties) {
    Integer supportedRegions = cameraProperties.getControlMaxRegionsAutoExposure();
    final boolean supported = supportedRegions != null && supportedRegions > 0;
    return supported;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!isSupported) {
      return;
    }

    Log.i("Camera", "updateExposurePoint | currentSetting: " + currentSetting);

    MeteringRectangle aeRect = null;
    try {
      aeRect = getCameraRegions.call().getAEMeteringRectangle();
      requestBuilder.set(
          CaptureRequest.CONTROL_AE_REGIONS,
          aeRect == null
              ? null
              : new MeteringRectangle[] {getCameraRegions.call().getAEMeteringRectangle()});
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public boolean getIsSupported() {
    return this.isSupported;
  }
}
