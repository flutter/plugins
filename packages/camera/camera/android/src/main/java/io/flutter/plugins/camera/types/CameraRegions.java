// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import android.annotation.TargetApi;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.os.Build;
import android.util.Size;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.CameraProperties;
import java.util.Arrays;

/**
 * Utility class that contains information regarding the camera's regions.
 *
 * <p>The regions information is used to calculate focus and exposure settings.
 */
public final class CameraRegions {

  /** Factory class that assists in creating a {@link CameraRegions} instance. */
  public static class Factory {
    /**
     * Creates a new instance of the {@link CameraRegions} class.
     *
     * <p>The {@link CameraProperties} and {@link CaptureRequest.Builder} classed are used to
     * determine if the device's camera supports distortion correction mode and calculate the
     * correct boundaries based on the outcome.
     *
     * @param cameraProperties Collection of the characteristics for the current camera device.
     * @param requestBuilder CaptureRequest builder containing current target and surface settings.
     * @return new instance of the {@link CameraRegions} class.
     */
    public static CameraRegions create(
        @NonNull CameraProperties cameraProperties,
        @NonNull CaptureRequest.Builder requestBuilder) {
      Size boundaries;

      // No distortion correction support
      if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
          && supportsDistortionCorrection(cameraProperties)) {
        // Get the current distortion correction mode
        Integer distortionCorrectionMode =
            requestBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE);

        // Return the correct boundaries depending on the mode
        android.graphics.Rect rect;
        if (distortionCorrectionMode == null
            || distortionCorrectionMode == CaptureRequest.DISTORTION_CORRECTION_MODE_OFF) {
          rect = cameraProperties.getSensorInfoPreCorrectionActiveArraySize();
        } else {
          rect = cameraProperties.getSensorInfoActiveArraySize();
        }

        // Set new region size
        boundaries = rect == null ? null : new Size(rect.width(), rect.height());
      } else {
        boundaries = cameraProperties.getSensorInfoPixelArraySize();
      }

      // Create new camera regions using new size
      return new CameraRegions(boundaries);
    }

    @TargetApi(Build.VERSION_CODES.P)
    private static boolean supportsDistortionCorrection(CameraProperties cameraProperties) {
      int[] availableDistortionCorrectionModes =
          cameraProperties.getDistortionCorrectionAvailableModes();
      if (availableDistortionCorrectionModes == null) {
        availableDistortionCorrectionModes = new int[0];
      }
      long nonOffModesSupported =
          Arrays.stream(availableDistortionCorrectionModes)
              .filter((value) -> value != CaptureRequest.DISTORTION_CORRECTION_MODE_OFF)
              .count();
      return nonOffModesSupported > 0;
    }
  }

  private final Size boundaries;

  private MeteringRectangle aeMeteringRectangle;
  private MeteringRectangle afMeteringRectangle;

  /**
   * Creates a new instance of the {@link CameraRegions} class.
   *
   * @param boundaries The area of the image sensor.
   */
  CameraRegions(Size boundaries) {
    assert (boundaries == null || boundaries.getWidth() > 0);
    assert (boundaries == null || boundaries.getHeight() > 0);

    this.boundaries = boundaries;
  }

  /**
   * Gets the {@link MeteringRectangle} on which the auto exposure will be applied.
   *
   * @return The {@link MeteringRectangle} on which the auto exposure will be applied.
   */
  public MeteringRectangle getAEMeteringRectangle() {
    return aeMeteringRectangle;
  }

  /**
   * Gets the {@link MeteringRectangle} on which the auto focus will be applied.
   *
   * @return The {@link MeteringRectangle} on which the auto focus will be applied.
   */
  public MeteringRectangle getAFMeteringRectangle() {
    return afMeteringRectangle;
  }

  /**
   * Gets the area of the image sensor.
   *
   * <p>If distortion correction is supported the size corresponds to the active pixels after any
   * geometric distortion correction has been applied. If distortion correction is not supported the
   * dimensions include the full pixel array, possibly including black calibration pixels.
   *
   * @return The area of the image sensor.
   */
  public Size getBoundaries() {
    return this.boundaries;
  }

  /** Resets the {@link MeteringRectangle} on which the auto exposure will be applied. */
  public void resetAutoExposureMeteringRectangle() {
    this.aeMeteringRectangle = null;
  }

  /**
   * Sets the coordinates which will form the centre of the exposure rectangle.
   *
   * @param x x – coordinate >= 0
   * @param y y – coordinate >= 0
   */
  public void setAutoExposureMeteringRectangleFromPoint(double x, double y) {
    this.aeMeteringRectangle = convertPointToMeteringRectangle(x, y);
  }

  /** Resets the {@link MeteringRectangle} on which the auto focus will be applied. */
  public void resetAutoFocusMeteringRectangle() {
    this.afMeteringRectangle = null;
  }

  /**
   * Sets the coordinates which will form the centre of the focus rectangle.
   *
   * @param x x – coordinate >= 0
   * @param y y – coordinate >= 0
   */
  public void setAutoFocusMeteringRectangleFromPoint(double x, double y) {
    this.afMeteringRectangle = convertPointToMeteringRectangle(x, y);
  }

  /**
   * Converts a point into a {@link MeteringRectangle} with the supplied coordinates as the centre
   * point.
   *
   * <p>Since the Camera API (due to cross-platform constraints) only accepts a point when
   * configuring a specific focus or exposure area and Android requires a rectangle to configure
   * these settings there is a need to convert the point into a rectangle. This method will create
   * the required rectangle with an arbitrarily size that is a 10th of the current viewport and the
   * coordinates as the centre point.
   *
   * @param x x - coordinate >= 0
   * @param y y - coordinate >= 0
   * @return The dimensions of the metering rectangle based on the supplied coordinates.
   */
  MeteringRectangle convertPointToMeteringRectangle(double x, double y) {
    assert (x >= 0 && x <= 1);
    assert (y >= 0 && y <= 1);

    // Interpolate the target coordinate
    int targetX = (int) Math.round(x * ((double) (boundaries.getWidth() - 1)));
    int targetY = (int) Math.round(y * ((double) (boundaries.getHeight() - 1)));
    // Since the Camera API only allows Determine the dimensions of the metering rectangle (10th of
    // the viewport)
    int targetWidth = (int) Math.round(((double) boundaries.getWidth()) / 10d);
    int targetHeight = (int) Math.round(((double) boundaries.getHeight()) / 10d);
    // Adjust target coordinate to represent top-left corner of metering rectangle
    targetX -= targetWidth / 2;
    targetY -= targetHeight / 2;
    // Adjust target coordinate as to not fall out of bounds
    if (targetX < 0) targetX = 0;
    if (targetY < 0) targetY = 0;
    int maxTargetX = boundaries.getWidth() - 1 - targetWidth;
    int maxTargetY = boundaries.getHeight() - 1 - targetHeight;
    if (targetX > maxTargetX) targetX = maxTargetX;
    if (targetY > maxTargetY) targetY = maxTargetY;

    // Build the metering rectangle
    return new MeteringRectangle(targetX, targetY, targetWidth, targetHeight, 1);
  }
}
