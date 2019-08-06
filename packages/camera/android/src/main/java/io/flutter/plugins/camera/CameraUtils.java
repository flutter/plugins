package io.flutter.plugins.camera;

import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.Point;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.util.Size;
import android.view.Display;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Provides various utilities for camera. */
public final class CameraUtils {

  private CameraUtils() {}

  static Size[] computeBestPreviewAndRecordingSize(
      Activity activity,
      StreamConfigurationMap streamConfigurationMap,
      int minHeight,
      int orientation,
      Size captureSize) {
    Size previewSize, videoSize;
    Size[] sizes = streamConfigurationMap.getOutputSizes(SurfaceTexture.class);

    // Preview size and video size should not be greater than screen resolution or 1080.
    Point screenResolution = new Point();

    Display display = activity.getWindowManager().getDefaultDisplay();
    display.getRealSize(screenResolution);

    final boolean swapWH = orientation % 180 == 90;
    int screenWidth = swapWH ? screenResolution.y : screenResolution.x;
    int screenHeight = swapWH ? screenResolution.x : screenResolution.y;

    List<Size> goodEnough = new ArrayList<>();
    for (Size s : sizes) {
      if (minHeight <= s.getHeight()
          && s.getWidth() <= screenWidth
          && s.getHeight() <= screenHeight
          && s.getHeight() <= 1080) {
        goodEnough.add(s);
      }
    }

    Collections.sort(goodEnough, new CompareSizesByArea());

    if (goodEnough.isEmpty()) {
      previewSize = sizes[0];
      videoSize = sizes[0];
    } else {
      float captureSizeRatio = (float) captureSize.getWidth() / captureSize.getHeight();

      previewSize = goodEnough.get(0);
      for (Size s : goodEnough) {
        if ((float) s.getWidth() / s.getHeight() == captureSizeRatio) {
          previewSize = s;
          break;
        }
      }

      Collections.reverse(goodEnough);
      videoSize = goodEnough.get(0);
      for (Size s : goodEnough) {
        if ((float) s.getWidth() / s.getHeight() == captureSizeRatio) {
          videoSize = s;
          break;
        }
      }
    }
    return new Size[] {videoSize, previewSize};
  }

  static Size computeBestCaptureSize(StreamConfigurationMap streamConfigurationMap) {
    // For still image captures, we use the largest available size.
    return Collections.max(
        Arrays.asList(streamConfigurationMap.getOutputSizes(ImageFormat.JPEG)),
        new CompareSizesByArea());
  }

  public static List<Map<String, Object>> getAvailableCameras(Activity activity)
      throws CameraAccessException {
    CameraManager cameraManager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
    String[] cameraNames = cameraManager.getCameraIdList();
    List<Map<String, Object>> cameras = new ArrayList<>();
    for (String cameraName : cameraNames) {
      HashMap<String, Object> details = new HashMap<>();
      CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
      details.put("name", cameraName);
      int sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
      details.put("sensorOrientation", sensorOrientation);

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
  }

  private static class CompareSizesByArea implements Comparator<Size> {
    @Override
    public int compare(Size lhs, Size rhs) {
      // We cast here to ensure the multiplications won't overflow.
      return Long.signum(
          (long) lhs.getWidth() * lhs.getHeight() - (long) rhs.getWidth() * rhs.getHeight());
    }
  }
}
