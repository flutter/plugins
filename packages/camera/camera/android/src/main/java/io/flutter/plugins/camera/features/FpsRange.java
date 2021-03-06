package io.flutter.plugins.camera.features;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import android.util.Range;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.types.FocusMode;

public class FpsRange implements CameraFeature<Range<Integer>> {
    private boolean isSupported;
    private Range<Integer> currentSetting;

    public FpsRange(CameraProperties cameraProperties) {
        Log.i("Camera", "getAvailableFpsRange");

        try {
            Range<Integer>[] ranges = cameraProperties.getControlAutoExposureAvailableTargetFpsRanges();

            if (ranges != null) {
                for (Range<Integer> range : ranges) {
                    int upper = range.getUpper();
                    Log.i("Camera", "[FPS Range Available] is:" + range);
                    if (upper >= 10) {
                        if (currentSetting == null || upper > currentSetting.getUpper()) {
                            currentSetting = range;
                        }
                    }
                }
            }
        } catch (Exception e) {
            // TODO: maybe just send a dart error back
//            pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
        }
        Log.i("Camera", "[FPS Range] is:" + currentSetting);
    }

    @Override
    public Range<Integer> getValue() {
        return currentSetting;
    }

    @Override
    public void setValue(Range<Integer> value) {
        this.currentSetting = value;
    }

    // Always supported
    @Override
    public boolean isSupported(CameraProperties cameraProperties, CameraCharacteristics cameraCharacteristics) {
       return true;
    }

    @Override
    public void updateBuilder(CaptureRequest.Builder requestBuilder) {
        if (currentSetting == null) {
            return;
        }

        requestBuilder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, currentSetting);
    }
}
