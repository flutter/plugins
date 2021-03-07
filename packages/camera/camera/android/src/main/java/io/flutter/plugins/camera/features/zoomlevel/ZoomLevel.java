package io.flutter.plugins.camera.features.zoomlevel;

import android.graphics.Rect;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/** Exposure offset makes the image brighter or darker. */
public class ZoomLevel implements CameraFeature<Float> {
  private boolean isSupported;
  private Float currentSetting = CameraZoom.DEFAULT_ZOOM_FACTOR;
  private CameraProperties cameraProperties;
  private CameraZoom cameraZoom;

  public ZoomLevel(CameraProperties cameraProperties) {
    this.cameraProperties = cameraProperties;
    this.cameraZoom =
        new CameraZoom(
            cameraProperties.getSensorInfoActiveArraySize(),
            cameraProperties.getScalerAvailableMaxDigitalZoom());
    this.isSupported = checkIsSupported(cameraProperties);
  }

  @Override
  public String getDebugName() {
    return "ZoomLevel";
  }

  @Override
  public Float getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Float value) {
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

    Log.i("Camera", "updateZoomLevel | currentSetting: " + currentSetting);

    final Rect computedZoom = cameraZoom.computeZoom(currentSetting);
    requestBuilder.set(CaptureRequest.SCALER_CROP_REGION, computedZoom);
  }

  public CameraZoom getCameraZoom() {
    return this.cameraZoom;
  }

  public boolean getIsSupported() {
    return this.isSupported;
  }
}
