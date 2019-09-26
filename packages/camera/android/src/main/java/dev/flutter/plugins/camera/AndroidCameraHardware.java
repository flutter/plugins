package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

/* package */ class AndroidCameraHardware implements CameraHardware {
  @NonNull
  private final CameraManager cameraManager;

  /* package */ AndroidCameraHardware(@NonNull CameraManager cameraManager) {
    this.cameraManager = cameraManager;
  }

  @NonNull
  @Override
  public List<CameraDetails> getAvailableCameras() throws CameraAccessException {
    String[] cameraNames = cameraManager.getCameraIdList();
    List<CameraDetails> cameras = new ArrayList<>();

    for (String cameraName : cameraNames) {
      CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);

      int sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);

      int lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING);
      String lensFacingName = null;
      switch (lensFacing) {
        case CameraMetadata.LENS_FACING_FRONT:
          lensFacingName = "front";
          break;
        case CameraMetadata.LENS_FACING_BACK:
          lensFacingName = "back";
          break;
        case CameraMetadata.LENS_FACING_EXTERNAL:
          lensFacingName = "external";
          break;
      }

      cameras.add(new CameraDetails(
          cameraName,
          sensorOrientation,
          lensFacingName
      ));
    }
    return cameras;
  }
}
