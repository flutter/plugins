package io.flutter.plugins.camera;

import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCaptureSession.CaptureCallback;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import androidx.annotation.NonNull;

class CameraCaptureCallback extends CaptureCallback {
  interface CameraCaptureStateListener {
    void onConverged();
    void onPrecapture();
    void onPrecaptureTimeout();
  }

  private final CameraCaptureStateListener cameraStateListener;

  private CameraState cameraState;
  private PictureCaptureRequest pictureCaptureRequest;

  public static CameraCaptureCallback create(
      @NonNull CameraCaptureStateListener cameraStateListener) {
    return new CameraCaptureCallback(cameraStateListener);
  }

  private CameraCaptureCallback(
      @NonNull CameraCaptureStateListener cameraStateListener) {
    cameraState = CameraState.STATE_PREVIEW;
    this.cameraStateListener = cameraStateListener;
    this.pictureCaptureRequest = pictureCaptureRequest;
  }

  public CameraState getCameraState() {
    return cameraState;
  }

  public void setCameraState(@NonNull CameraState state) {
    cameraState = state;

    if (pictureCaptureRequest != null && state == CameraState.STATE_WAITING_PRECAPTURE_DONE) {
      pictureCaptureRequest.setState(
          PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_DONE);
    }
  }

  public void setPictureCaptureRequest(@NonNull PictureCaptureRequest pictureCaptureRequest) {
    this.pictureCaptureRequest = pictureCaptureRequest;
  }

  private void process(CaptureResult result) {
    Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
    Integer afState = result.get(CaptureResult.CONTROL_AF_STATE);

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
        } else if (afState == CaptureRequest.CONTROL_AF_STATE_PASSIVE_SCAN
            || afState == CaptureRequest.CONTROL_AF_STATE_FOCUSED_LOCKED
            || afState == CaptureRequest.CONTROL_AF_STATE_NOT_FOCUSED_LOCKED) {
          // CONTROL_AE_STATE can be null on some devices

          if (aeState == null || aeState == CaptureRequest.CONTROL_AE_STATE_CONVERGED) {
            cameraStateListener.onConverged();
          } else {
            cameraStateListener.onPrecapture();
          }
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
        }
        break;
      }

      case STATE_WAITING_PRECAPTURE_DONE:
      {
        // CONTROL_AE_STATE can be null on some devices
        if (aeState == null || aeState != CaptureResult.CONTROL_AE_STATE_PRECAPTURE) {
          cameraStateListener.onConverged();
        } else if (pictureCaptureRequest != null && pictureCaptureRequest.hitPreCaptureTimeout()) {
          // Log.i(TAG, "===> Hit precapture timeout");
          cameraStateListener.onPrecaptureTimeout();
        }
        break;
      }
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
}
