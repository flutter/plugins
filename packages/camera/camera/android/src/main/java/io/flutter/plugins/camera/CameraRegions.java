package io.flutter.plugins.camera;

import android.hardware.camera2.params.MeteringRectangle;
import android.util.Size;

public final class CameraRegions {
  private MeteringRectangle aeMeteringRectangle;
  private MeteringRectangle afMeteringRectangle;
  private Size maxBoundaries;

  public CameraRegions(Size maxBoundaries) {
    assert (maxBoundaries == null || maxBoundaries.getWidth() > 0);
    assert (maxBoundaries == null || maxBoundaries.getHeight() > 0);
    this.maxBoundaries = maxBoundaries;
  }

  public MeteringRectangle getAEMeteringRectangle() {
    return aeMeteringRectangle;
  }

  public MeteringRectangle getAFMeteringRectangle() {
    return afMeteringRectangle;
  }

  public Size getMaxBoundaries() {
    return this.maxBoundaries;
  }

  public void resetAutoExposureMeteringRectangle() {
    this.aeMeteringRectangle = null;
  }

  public void setAutoExposureMeteringRectangleFromPoint(double x, double y) {
    this.aeMeteringRectangle = getMeteringRectangleForPoint(maxBoundaries, x, y);
  }

  public void resetAutoFocusMeteringRectangle() {
    this.afMeteringRectangle = null;
  }

  public void setAutoFocusMeteringRectangleFromPoint(double x, double y) {
    this.afMeteringRectangle = getMeteringRectangleForPoint(maxBoundaries, x, y);
  }

  public MeteringRectangle getMeteringRectangleForPoint(Size maxBoundaries, double x, double y) {
    assert (x >= 0 && x <= 1);
    assert (y >= 0 && y <= 1);
    if (maxBoundaries == null)
      throw new IllegalStateException(
          "Functionality for managing metering rectangles is unavailable as this CameraRegions instance was initialized with null boundaries.");

    // Interpolate the target coordinate
    int targetX = (int) Math.round(x * ((double) (maxBoundaries.getWidth() - 1)));
    int targetY = (int) Math.round(y * ((double) (maxBoundaries.getHeight() - 1)));
    // Determine the dimensions of the metering triangle (10th of the viewport)
    int targetWidth = (int) Math.round(((double) maxBoundaries.getWidth()) / 10d);
    int targetHeight = (int) Math.round(((double) maxBoundaries.getHeight()) / 10d);
    // Adjust target coordinate to represent top-left corner of metering rectangle
    targetX -= targetWidth / 2;
    targetY -= targetHeight / 2;
    // Adjust target coordinate as to not fall out of bounds
    if (targetX < 0) targetX = 0;
    if (targetY < 0) targetY = 0;
    int maxTargetX = maxBoundaries.getWidth() - 1 - targetWidth;
    int maxTargetY = maxBoundaries.getHeight() - 1 - targetHeight;
    if (targetX > maxTargetX) targetX = maxTargetX;
    if (targetY > maxTargetY) targetY = maxTargetY;

    // Build the metering rectangle
    return new MeteringRectangle(targetX, targetY, targetWidth, targetHeight, 1);
  }
}
