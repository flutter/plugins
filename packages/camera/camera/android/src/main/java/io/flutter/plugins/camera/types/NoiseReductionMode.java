package io.flutter.plugins.camera.types;

/**
 * Only supports fast mode for now.
 */
public enum NoiseReductionMode {
    fast("fast");

    private final String strValue;

    NoiseReductionMode(String strValue) {
        this.strValue = strValue;
    }

    public static NoiseReductionMode getValueForString(String modeStr) {
        for (NoiseReductionMode value : values()) {
            if (value.strValue.equals(modeStr)) return value;
        }
        return null;
    }

    @Override
    public String toString() {
        return strValue;
    }
}
