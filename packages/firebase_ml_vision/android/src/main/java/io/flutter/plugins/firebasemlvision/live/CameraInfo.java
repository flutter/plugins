package io.flutter.plugins.firebasemlvision.live;

import android.annotation.TargetApi;
import android.content.Context;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.os.Build;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class CameraInfo {
  public static List<Map<String, Object>> getAvailableCameras(Context context)
      throws CameraInfoException {
    try {
      CameraManager cameraManager =
          (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
      assert cameraManager != null;
      String[] cameraNames = cameraManager.getCameraIdList();
      List<Map<String, Object>> cameras = new ArrayList<>();
      for (String cameraName : cameraNames) {
        HashMap<String, Object> details = new HashMap<>();
        CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
        details.put("name", cameraName);
        @SuppressWarnings("ConstantConditions")
        int lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING);
        switch (lensFacing) {
          case CameraMetadata.LENS_FACING_FRONT:
            details.put("lensFacing", "front");
            break;
          case CameraMetadata.LENS_FACING_BACK:
            details.put("lensFacing", "back");
            break;
          case CameraMetadata.LENS_FACING_EXTERNAL:
            details.put("lensFacing", "external");
            break;
        }
        cameras.add(details);
      }
      return cameras;
    } catch (CameraAccessException e) {
      throw new CameraInfoException(e.getMessage());
    }
  }
}
