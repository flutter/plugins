package dev.flutter.plugins.camera;

import android.content.pm.PackageManager;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;

import io.flutter.plugin.common.PluginRegistry;

/* package */ class CameraPermissions {
  private static final int CAMERA_REQUEST_ID = 9796;

  private final CameraPermissionsDelegate delegate;
  private boolean ongoing = false;

  /* package */ CameraPermissions(@NonNull CameraPermissionsDelegate delegate) {
    this.delegate = delegate;
  }

  public void requestPermissions(boolean enableAudio, ResultCallback callback) {
    if (ongoing) {
      callback.onResult("cameraPermission", "Camera permission request ongoing");
    }
    if (!delegate.hasCameraPermission() || (enableAudio && !delegate.hasAudioPermission())) {
      delegate.addRequestPermissionsResultListener(
          new CameraRequestPermissionsListener(
              (String errorCode, String errorDescription) -> {
                ongoing = false;
                callback.onResult(errorCode, errorDescription);
              }));
      ongoing = true;
      delegate.requestPermission(enableAudio, CAMERA_REQUEST_ID);
    } else {
      // Permissions already exist. Call the callback with success.
      callback.onResult(null, null);
    }
  }

  private static class CameraRequestPermissionsListener
      implements PluginRegistry.RequestPermissionsResultListener {
    final ResultCallback callback;

    private CameraRequestPermissionsListener(ResultCallback callback) {
      this.callback = callback;
    }

    @Override
    public boolean onRequestPermissionsResult(int id, String[] permissions, int[] grantResults) {
      if (id == CAMERA_REQUEST_ID) {
        // TODO(mattcarroll): fix bug where granting 1st permission and denying 2nd crashes
        // due to submitting a reply twice.
        if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
          callback.onResult("cameraPermission", "MediaRecorderCamera permission not granted");
        } else if (grantResults.length > 1
            && grantResults[1] != PackageManager.PERMISSION_GRANTED) {
          callback.onResult("cameraPermission", "MediaRecorderAudio permission not granted");
        } else {
          callback.onResult(null, null);
        }
        return true;
      }
      return false;
    }
  }

  interface CameraPermissionsDelegate {
    boolean hasCameraPermission();

    boolean hasAudioPermission();

    void requestPermission(boolean enableAudio, final @IntRange(from = 0) int requestCode);

    void addRequestPermissionsResultListener(@NonNull PluginRegistry.RequestPermissionsResultListener listener);
  }

  interface ResultCallback {
    void onResult(String errorCode, String errorDescription);
  }
}
