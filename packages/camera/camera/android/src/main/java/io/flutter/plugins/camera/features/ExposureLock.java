package io.flutter.plugins.camera.features;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.util.Log;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.CameraRegions;
import io.flutter.plugins.camera.types.ExposureMode;
import io.flutter.plugins.camera.types.FlashMode;

/**
 * Exposure lock controls whether or not exposure mode is currenty locked or
 * automatically metering.
 */
public class ExposureLock implements CameraFeature<ExposureMode> {
    private boolean isSupported;
    private ExposureMode currentSetting = ExposureMode.auto;
    private CameraRegions cameraRegions;

    public ExposureLock(CameraRegions cameraRegions) {
        this.cameraRegions = cameraRegions;
    }

    @Override
    public ExposureMode getValue() {
        return currentSetting;
    }

    @Override
    public void setValue(ExposureMode value) {
        this.currentSetting = value;
    }

    // Available on all devices.
    @Override
    public boolean isSupported(CameraProperties cameraProperties) {
        return true;
    }

    @Override
    public void updateBuilder(CaptureRequest.Builder requestBuilder) {
        Log.i("Camera", "updateExposureMode");

        // Don't try to set if the current camera doesn't support it.
        if (!isSupported) {
            return;
        }

        // Applying auto exposure
        MeteringRectangle aeRect = cameraRegions.getAEMeteringRectangle();
        requestBuilder.set(
                CaptureRequest.CONTROL_AE_REGIONS,
                aeRect == null ? null : new MeteringRectangle[] {cameraRegions.getAEMeteringRectangle()});

        switch (currentSetting) {
            case locked:
                requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, true);
                break;
            case auto:
            default:
                requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
                break;
        }
    }
}
