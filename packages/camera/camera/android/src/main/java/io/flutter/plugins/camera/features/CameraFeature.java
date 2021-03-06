package io.flutter.plugins.camera.features;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;

import io.flutter.plugins.camera.CameraProperties;

public interface CameraFeature<T> {
    /**
     * Get the current value of this feature's setting.
     * @return
     */
    public T getValue();

    /**
     * Set a new value for this feature's setting.
     * @param value
     */
    public void setValue(T value);

    /**
     * Returns whether or not this feature is supported on the
     * given camera properties.
     * @return
     */
    public boolean isSupported(CameraProperties cameraProperties, CameraCharacteristics cameraCharacteristics);

    /**
     * Update the setting in a provided request builder.
     * @param requestBuilder
     */
    public void updateBuilder(CaptureRequest.Builder requestBuilder);
}
