package io.flutter.plugins.camera.features;

/**
 * This represents the exposure offset value. It holds the minimum and
 * maximum values, as well as the current setting value.
 */
public class ExposureOffsetValue {
    final public double min;
    final public double max;
    final public double value;

    public ExposureOffsetValue(double min, double max, double value) {
        this.min = min;
        this.max = max;
        this.value = value;
    }
}
