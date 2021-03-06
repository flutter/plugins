package io.flutter.plugins.camera.features;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.types.FlashMode;

public class Flash implements CameraFeature<FlashMode> {
    private boolean isSupported;
    private FlashMode currentSetting;

    @Override
    public FlashMode getValue() {
        return currentSetting;
    }

    @Override
    public void setValue(FlashMode value) {
        this.currentSetting = value;
    }

    @Override
    public boolean isSupported(CameraProperties cameraProperties, CameraCharacteristics cameraCharacteristics) {
        Boolean available = cameraProperties.getFlashInfoAvailable();
        final boolean supported = available != null && available;
        isSupported = supported;
        return supported;
    }

    @Override
    public void updateBuilder(CaptureRequest.Builder requestBuilder) {
        Log.i("Camera", "updateFlash");

        // Don't try to set flash enabled if the current camera doesn't
        // support it.
        if (!isSupported) {
            return;
        }

        switch (currentSetting) {
            case off:
                requestBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
                requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                break;

            case always:
                requestBuilder.set(
                        CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
                requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                break;

            case torch:
                requestBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
                requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_TORCH);
                break;

            case auto:
                requestBuilder.set(
                        CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
                requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                break;

            // TODO: to be implemented someday. Need to add it to dart/iOS as another flash mode setting.
            //      case autoRedEye:
            //        requestBuilder.set(CaptureRequest.CONTROL_AE_MODE,
            //                CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH_REDEYE);
            //        requestBuilder.set(CaptureRequest.FLASH_MODE,
            //                CaptureRequest.FLASH_MODE_OFF);
            //        break;
        }
    }
}
