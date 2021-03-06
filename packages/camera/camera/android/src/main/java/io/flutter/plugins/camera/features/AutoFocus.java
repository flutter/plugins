package io.flutter.plugins.camera.features;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.types.FocusMode;

public class AutoFocus implements CameraFeature<FocusMode> {
//    private final boolean recordingVideo;
    private boolean isSupported;
    private FocusMode currentSetting;

//    public AutoFocus(boolean recordingVideo) {
//        this.recordingVideo = recordingVideo;
//    }

    @Override
    public FocusMode getValue() {
        return currentSetting;
    }

    @Override
    public void setValue(FocusMode value) {
        this.currentSetting = value;
    }

    @Override
    public boolean isSupported(CameraProperties cameraProperties, CameraCharacteristics cameraCharacteristics) {
        int[] modes = cameraProperties.getControlAutoFocusAvailableModes();
        Log.i("Camera", "checkAutoFocusSupported | modes:");
        for (int mode : modes) {
            Log.i("Camera", "checkAutoFocusSupported | ==> " + mode);
        }

        // Check if fixed focal length lens. If LENS_INFO_MINIMUM_FOCUS_DISTANCE=0, then this is fixed.
        // Can be null on some devices.
        final Float minFocus = cameraProperties.getLensInfoMinimumFocusDistance();
        // final Float maxFocus = cameraCharacteristics.get(CameraCharacteristics.LENS_INFO_HYPERFOCAL_DISTANCE);

        // Value can be null on some devices:
        // https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#LENS_INFO_MINIMUM_FOCUS_DISTANCE
        boolean isFixedLength;
        if (minFocus == null) {
            isFixedLength = true;
        } else {
            isFixedLength = minFocus == 0;
        }
        Log.i("Camera", "checkAutoFocusSupported | minFocus " + minFocus);

        final boolean supported = !isFixedLength
                && !(modes == null
                || modes.length == 0
                || (modes.length == 1 && modes[0] == CameraCharacteristics.CONTROL_AF_MODE_OFF));
        isSupported = supported;
        return supported;
    }

    @Override
    public void updateBuilder(CaptureRequest.Builder requestBuilder) {
        Log.i("Camera", "updateFocusMode currentFocusMode: " + currentSetting);

        if (!isSupported) {
            return;
        }

        switch (currentSetting) {
            case locked:
                requestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO);
                break;

            case auto:
                requestBuilder.set(
                        CaptureRequest.CONTROL_AF_MODE,
//                        recordingVideo
//                                ? CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO
//                                :
                                CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
            default:
                break;
        }

    }
}
