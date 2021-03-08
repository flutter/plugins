// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.autofocus;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

public class AutoFocusFeature extends CameraFeature<FocusMode> {
  private FocusMode currentSetting = FocusMode.auto;

  // When we switch recording modes we re-create this feature with
  // the appropriate setting here.
  private final boolean recordingVideo;

  public AutoFocusFeature(CameraProperties cameraProperties, boolean recordingVideo) {
    super(cameraProperties);
    this.recordingVideo = recordingVideo;
  }

  @Override
  public String getDebugName() {
    return "AutoFocus";
  }

  @Override
  public FocusMode getValue() {
    return currentSetting;
  }

  @Override
  public void setValue(FocusMode value) {
    this.currentSetting = value;

    //    /*
    //     * If we are locking AF, we should perform a one-time
    //     */
    //    switch (currentSetting) {
    //      case locked:
    //        requestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO);
    //        unlockAutoFocus.run();
    //        break;
    //
    //      case auto:
    //        requestBuilder.set(
    //                CaptureRequest.CONTROL_AF_MODE,
    //                recordingVideo
    //                        ? CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO
    //                        : CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
    //      default:
    //        break;
    //    }
  }

  @Override
  public boolean checkIsSupported() {
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

    final boolean supported =
        !isFixedLength
            && !(modes.length == 0
                || (modes.length == 1 && modes[0] == CameraCharacteristics.CONTROL_AF_MODE_OFF));

    return supported;
  }

  @Override
  public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    if (!checkIsSupported()) {
      return;
    }

    Log.i("Camera", "updateFocusMode | currentSetting: " + currentSetting);

    switch (currentSetting) {
      case locked:
        /** If we're locking AF we should do a one-time focus, then set the AF to idle */
        requestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO);
        break;

      case auto:
        requestBuilder.set(
            CaptureRequest.CONTROL_AF_MODE,
            recordingVideo
                ? CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO
                : CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
      default:
        break;
    }
  }
}
