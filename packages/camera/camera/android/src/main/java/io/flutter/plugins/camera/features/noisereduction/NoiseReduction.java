package io.flutter.plugins.camera.features.noisereduction;

import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/**
 * This can either be enabled or disabled. Only full capability devices can set this to off. Legacy
 * and full support the fast mode.
 * https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#NOISE_REDUCTION_AVAILABLE_NOISE_REDUCTION_MODES
 */
public class NoiseReduction implements CameraFeature<NoiseReductionMode> {
  private boolean isSupported;
  private NoiseReductionMode currentSetting;

  @Override
  public NoiseReductionMode getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(NoiseReductionMode value) {
    this.currentSetting = value;
  }

  @Override
  public boolean isSupported(CameraProperties cameraProperties) {
    /**
     * Available settings: public static final int NOISE_REDUCTION_MODE_FAST = 1; public static
     * final int NOISE_REDUCTION_MODE_HIGH_QUALITY = 2; public static final int
     * NOISE_REDUCTION_MODE_MINIMAL = 3; public static final int NOISE_REDUCTION_MODE_OFF = 0;
     * public static final int NOISE_REDUCTION_MODE_ZERO_SHUTTER_LAG = 4;
     *
     * <p>Full-capability camera devices will always support OFF and FAST. Camera devices that
     * support YUV_REPROCESSING or PRIVATE_REPROCESSING will support ZERO_SHUTTER_LAG.
     * Legacy-capability camera devices will only support FAST mode.
     */

    // Can be null on some devices.
    int[] modes = cameraProperties.getAvailableNoiseReductionModes();

    /// If there's at least one mode available then we are supported.
    return modes != null && modes.length > 0;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!isSupported) {
      return;
    }

    Log.i("Camera", "updateNoiseReduction | currentSetting: " + currentSetting);

    // Always use fast mode.
    requestBuilder.set(
        CaptureRequest.NOISE_REDUCTION_MODE, CaptureRequest.NOISE_REDUCTION_MODE_FAST);
  }
}
