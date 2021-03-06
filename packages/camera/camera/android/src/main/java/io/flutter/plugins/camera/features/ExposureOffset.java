package io.flutter.plugins.camera.features;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Log;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.CameraRegions;
import io.flutter.plugins.camera.types.ExposureMode;

/**
 * Exposure offset makes the image brighter or darker.
 */
public class ExposureOffset implements CameraFeature<Integer> {
    private boolean isSupported;
    private Integer currentSetting;

    @Override
    public Integer getValue() {
        return currentSetting;
    }

    @Override
    public void setValue(Integer value) {
        this.currentSetting = value;
    }

    // Available on all devices.
    @Override
    public boolean isSupported(CameraProperties cameraProperties, CameraCharacteristics cameraCharacteristics) {
        return true;
    }

    @Override
    public void updateBuilder(CaptureRequest.Builder requestBuilder) {
        Log.i("Camera", "updateExposureOffset");

        // Don't try to set if the current camera doesn't support it.
        if (!isSupported) {
            return;
        }

        requestBuilder.set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, currentSetting);
    }
}
