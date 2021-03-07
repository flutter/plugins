// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.util.Size;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
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

  static CameraManager getCameraManager(Context context) {
    return (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
  }

  static PlatformChannel.DeviceOrientation getDeviceOrientationFromDegrees(int degrees) {
    // Round to the nearest 90 degrees.
    degrees = (int) (Math.round(degrees / 90.0) * 90) % 360;
    // Determine the corresponding device orientation.
    switch (degrees) {
      case 90:
        return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
      case 180:
        return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
      case 270:
        return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
      case 0:
      default:
        return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
    }
  }

  static String serializeDeviceOrientation(PlatformChannel.DeviceOrientation orientation) {
    if (orientation == null)
      throw new UnsupportedOperationException("Could not serialize null device orientation.");
    switch (orientation) {
      case PORTRAIT_UP:
        return "portraitUp";
      case PORTRAIT_DOWN:
        return "portraitDown";
      case LANDSCAPE_LEFT:
        return "landscapeLeft";
      case LANDSCAPE_RIGHT:
        return "landscapeRight";
      default:
        throw new UnsupportedOperationException(
            "Could not serialize device orientation: " + orientation.toString());
    }
  }

  static PlatformChannel.DeviceOrientation deserializeDeviceOrientation(String orientation) {
    if (orientation == null)
      throw new UnsupportedOperationException("Could not deserialize null device orientation.");
    switch (orientation) {
      case "portraitUp":
        return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
      case "portraitDown":
        return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
      case "landscapeLeft":
        return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
      case "landscapeRight":
        return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
      default:
        throw new UnsupportedOperationException(
            "Could not deserialize device orientation: " + orientation);
    }
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
