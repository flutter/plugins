package dev.flutter.plugins.camera;

import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraManager;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/* package */ class AndroidCameraHardware implements CameraHardware {
  @NonNull
  private final CameraManager cameraManager;

  /* package */ AndroidCameraHardware(@NonNull CameraManager cameraManager) {
    this.cameraManager = cameraManager;
  }

  @NonNull
  @Override
  public List<CameraDetails> getAvailableCameras() throws CameraAccessException {
    List<Map<String, Object>> allCameraDetailsSerialized = CameraUtils.getAvailableCameras(cameraManager);
    List<CameraDetails> allCameraDetails = new ArrayList<>();
    for (Map<String, Object> serializedDetails : allCameraDetailsSerialized) {
      allCameraDetails.add(new CameraDetails(
          (String) serializedDetails.get("name"),
          (Integer) serializedDetails.get("sensorOrientation"),
          (String) serializedDetails.get("lensFacing")
      ));
    }
    return allCameraDetails;
  }
}
