package io.flutter.plugins.camera;

import android.graphics.Rect;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.os.Build.VERSION_CODES;
import android.util.Range;
import android.util.Rational;
import android.util.Size;
import androidx.annotation.RequiresApi;

public interface CameraProperties {
  String getCameraName();

  Range<Integer>[] getControlAutoExposureAvailableTargetFpsRanges();

  Range<Integer> getControlAutoExposureCompensationRange();

  Rational getControlAutoExposureCompensationStep();

  int[] getControlAutoFocusAvailableModes();

  Integer getControlMaxRegionsAutoExposure();

  Integer getControlMaxRegionsAutoFocus();

  int[] getDistortionCorrectionAvailableModes();

  Boolean getFlashInfoAvailable();

  int getLensFacing();

  Float getLensInfoMinimumFocusDistance();

  Float getScalerAvailableMaxDigitalZoom();

  Rect getSensorInfoActiveArraySize();

  Size getSensorInfoPixelArraySize();

  Rect getSensorInfoPreCorrectionActiveArraySize();

  int getSensorOrientation();
}

class CameraPropertiesImpl implements CameraProperties {
  private final CameraCharacteristics cameraCharacteristics;
  private final String cameraName;

  public CameraPropertiesImpl(String cameraName, CameraManager cameraManager)
      throws CameraAccessException {
    this.cameraName = cameraName;
    this.cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraName);
  }

  @Override
  public String getCameraName() {
    return cameraName;
  }

  @Override
  public Range<Integer>[] getControlAutoExposureAvailableTargetFpsRanges() {
    return cameraCharacteristics.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES);
  }

  @Override
  public Range<Integer> getControlAutoExposureCompensationRange() {
    return cameraCharacteristics.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE);
  }

  @Override
  public Rational getControlAutoExposureCompensationStep() {
    return cameraCharacteristics.get(CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP);
  }

  @Override
  public int[] getControlAutoFocusAvailableModes() {
    return cameraCharacteristics.get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES);
  }

  @Override
  public Integer getControlMaxRegionsAutoExposure() {
    return cameraCharacteristics.get(CameraCharacteristics.CONTROL_MAX_REGIONS_AE);
  }

  @Override
  public Integer getControlMaxRegionsAutoFocus() {
    return cameraCharacteristics.get(CameraCharacteristics.CONTROL_MAX_REGIONS_AF);
  }

  @RequiresApi(api = VERSION_CODES.P)
  @Override
  public int[] getDistortionCorrectionAvailableModes() {
    return cameraCharacteristics.get(CameraCharacteristics.DISTORTION_CORRECTION_AVAILABLE_MODES);
  }

  @Override
  public Boolean getFlashInfoAvailable() {
    return cameraCharacteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE);
  }

  @Override
  public int getLensFacing() {
    return cameraCharacteristics.get(CameraCharacteristics.LENS_FACING);
  }

  @Override
  public Float getLensInfoMinimumFocusDistance() {
    return cameraCharacteristics.get(CameraCharacteristics.LENS_INFO_MINIMUM_FOCUS_DISTANCE);
  }

  @Override
  public Float getScalerAvailableMaxDigitalZoom() {
    return cameraCharacteristics.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM);
  }

  @Override
  public Rect getSensorInfoActiveArraySize() {
    return cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE);
  }

  @Override
  public Size getSensorInfoPixelArraySize() {
    return cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE);
  }

  @RequiresApi(api = VERSION_CODES.M)
  @Override
  public Rect getSensorInfoPreCorrectionActiveArraySize() {
    return cameraCharacteristics.get(
        CameraCharacteristics.SENSOR_INFO_PRE_CORRECTION_ACTIVE_ARRAY_SIZE);
  }

  @Override
  public int getSensorOrientation() {
    return cameraCharacteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
  }
}
