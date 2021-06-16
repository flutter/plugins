// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCaptureSession.CaptureCallback;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.types.CaptureTimeoutsWrapper;

class CameraCaptureCallback extends CaptureCallback {
  private final CameraCaptureStateListener cameraStateListener;
  private CameraState cameraState;
  private final CaptureTimeoutsWrapper captureTimeouts;

  private CameraCaptureCallback(
      @NonNull CameraCaptureStateListener cameraStateListener,
      @NonNull CaptureTimeoutsWrapper captureTimeouts) {
    cameraState = CameraState.STATE_PREVIEW;
    this.cameraStateListener = cameraStateListener;
    this.captureTimeouts = captureTimeouts;
  }

  public static CameraCaptureCallback create(
      @NonNull CameraCaptureStateListener cameraStateListener,
      @NonNull CaptureTimeoutsWrapper captureTimeouts) {
    return new CameraCaptureCallback(cameraStateListener, captureTimeouts);
  }

  public CameraState getCameraState() {
    return cameraState;
  }

  public void setCameraState(@NonNull CameraState state) {
    cameraState = state;
  }

  private void process(CaptureResult result) {
    Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
    Integer afState = result.get(CaptureResult.CONTROL_AF_STATE);

    if (cameraState != CameraState.STATE_PREVIEW) {
      Log.i(
          "Camera",
          "CameraCaptureCallback | state: "
              + cameraState
              + " | afState: "
              + afState
              + " | aeState: "
              + aeState);
    }

    switch (cameraState) {
      case STATE_PREVIEW:
        {
          // We have nothing to do when the camera preview is working normally.
          break;
        }
      case STATE_WAITING_FOCUS:
        {
          if (afState == null) {
            return;
          } else if (afState == CaptureResult.CONTROL_AF_STATE_FOCUSED_LOCKED
              || afState == CaptureResult.CONTROL_AF_STATE_NOT_FOCUSED_LOCKED) {
            handleWaitingFocusState(aeState);
          } else if (captureTimeouts.getPreCaptureFocusing().getIsExpired()) {
            Log.w("Camera", "Focus timeout, moving on with capture");
            handleWaitingFocusState(aeState);
          }

          break;
        }
      case STATE_WAITING_PRECAPTURE_START:
        {
          // CONTROL_AE_STATE can be null on some devices
          if (aeState == null
              || aeState == CaptureResult.CONTROL_AE_STATE_CONVERGED
              || aeState == CaptureResult.CONTROL_AE_STATE_PRECAPTURE
              || aeState == CaptureResult.CONTROL_AE_STATE_FLASH_REQUIRED) {
            setCameraState(CameraState.STATE_WAITING_PRECAPTURE_DONE);
          } else if (captureTimeouts.getPreCaptureMetering().getIsExpired()) {
            Log.w(
                "Camera",
                "Metering timeout waiting for pre-capture to start, moving on with capture");

            setCameraState(CameraState.STATE_WAITING_PRECAPTURE_DONE);
          }
          break;
        }
      case STATE_WAITING_PRECAPTURE_DONE:
        {
          // CONTROL_AE_STATE can be null on some devices
          if (aeState == null || aeState != CaptureResult.CONTROL_AE_STATE_PRECAPTURE) {
            cameraStateListener.onConverged();
          } else if (captureTimeouts.getPreCaptureMetering().getIsExpired()) {
            Log.w(
                "Camera",
                "Metering timeout waiting for pre-capture to finish, moving on with capture");
            cameraStateListener.onConverged();
          }

          break;
        }
    }
  }

  private void handleWaitingFocusState(Integer aeState) {
    // CONTROL_AE_STATE can be null on some devices
    if (aeState == null || aeState == CaptureRequest.CONTROL_AE_STATE_CONVERGED) {
      cameraStateListener.onConverged();
    } else {
      cameraStateListener.onPrecapture();
    }
  }

  @Override
  public void onCaptureProgressed(
      @NonNull CameraCaptureSession session,
      @NonNull CaptureRequest request,
      @NonNull CaptureResult partialResult) {
    process(partialResult);
  }

  @Override
  public void onCaptureCompleted(
      @NonNull CameraCaptureSession session,
      @NonNull CaptureRequest request,
      @NonNull TotalCaptureResult result) {
    process(result);
  }

  interface CameraCaptureStateListener {
    void onConverged();

    void onPrecapture();
  }
}
