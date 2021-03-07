package io.flutter.plugins.camera.features.sensororientation;

import android.app.Activity;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.DartMessenger;
import io.flutter.plugins.camera.features.CameraFeature;

public class SensorOrientation implements CameraFeature<Integer> {
  private boolean isSupported;
  private Integer currentSetting = 0;
  private final DeviceOrientationManager deviceOrientationListener;
  private PlatformChannel.DeviceOrientation lockedCaptureOrientation;

  public SensorOrientation(
      CameraProperties cameraProperties, Activity activity, DartMessenger dartMessenger) {
    setValue(cameraProperties.getSensorOrientation());

    boolean isFrontFacing = cameraProperties.getLensFacing() == CameraMetadata.LENS_FACING_FRONT;
    deviceOrientationListener =
        DeviceOrientationManager.create(activity, dartMessenger, isFrontFacing, currentSetting);
    deviceOrientationListener.start();

    this.isSupported = checkIsSupported(cameraProperties);
  }

  @Override
  public String getDebugName() {
    return "SensorOrientation";
  }

  @Override
  public Integer getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(Integer value) {
    this.currentSetting = value;
  }

  @Override
  public boolean checkIsSupported(CameraProperties cameraProperties) {
    return true;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!isSupported) {
      return;
    }
  }

  public DeviceOrientationManager getDeviceOrientationManager() {
    return this.deviceOrientationListener;
  }

  public boolean getIsSupported() {
    return this.isSupported;
  }

  public void lockCaptureOrientation(PlatformChannel.DeviceOrientation orientation) {
    this.lockedCaptureOrientation = orientation;
  }

  public void unlockCaptureOrientation() {
    this.lockedCaptureOrientation = null;
  }

  public PlatformChannel.DeviceOrientation getLockedCaptureOrientation() {
    return this.lockedCaptureOrientation;
  }
}
