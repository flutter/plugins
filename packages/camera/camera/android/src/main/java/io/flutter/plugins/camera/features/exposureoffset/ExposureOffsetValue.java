package io.flutter.plugins.camera.features.exposureoffset;

/**
 * This represents the exposure offset value. It holds the minimum and maximum values, as well as
 * the current setting value.
 */
public class ExposureOffsetValue {
  public final double min;
  public final double max;
  public final double value;

  public ExposureOffsetValue(double min, double max, double value) {
    this.min = min;
    this.max = max;
    this.value = value;
  }
}
